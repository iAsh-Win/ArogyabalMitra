import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'inventory_requests_screen.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<dynamic> _inventoryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventoryData();
  }

  Future<void> _fetchInventoryData() async {
    try {
      final authService = await AuthService.create();
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token is missing.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.anganwadi_supplements),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _inventoryItems = data['supplements'] ?? [];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch inventory data: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _requestNewInventory() async {
    final requestData = {
      "supplements": [
        {"id": "fcffe9a4-2741-41e1-b607-c18b917d2050", "quantity": 10},
        {"id": "e62a5f16-8c4b-4c37-a112-fdc53d36c30b", "quantity": 5},
      ],
    };

    try {
      final authService = await AuthService.create();
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token is missing.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.request_supplements),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final message =
            responseData['message'] ?? 'Request created successfully';
        final requestId = responseData['request_id'] ?? 'N/A';
        final requestDate = responseData['request_date'] ?? 'N/A';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$message\nRequest ID: $requestId\nRequest Date: $requestDate',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'An error occurred.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showRequestInventoryDialog() async {
    final lowStockItems =
        _inventoryItems
            .where((item) => item['quantity'] >= 0 && item['quantity'] <= 20)
            .toList();
    final allSupplements = List.from(
      _inventoryItems,
    ); // Clone the full inventory list
    final selectedSupplements = Map<String, TextEditingController>.fromEntries(
      lowStockItems.map(
        (item) => MapEntry(item['id'], TextEditingController(text: '0')),
      ),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Request Inventory'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedSupplements.length,
                        itemBuilder: (context, index) {
                          final itemId = selectedSupplements.keys.elementAt(
                            index,
                          );
                          final item = allSupplements.firstWhere(
                            (supplement) => supplement['id'] == itemId,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['supplement_name']} (${item['quantity']} ${item['unit']})',
                                    style: TextStyle(
                                      color:
                                          item['quantity'] <= 20
                                              ? Colors.orange
                                              : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: selectedSupplements[itemId],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'Qty',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final remainingSupplements =
                            allSupplements
                                .where(
                                  (item) =>
                                      !selectedSupplements.containsKey(
                                        item['id'],
                                      ),
                                )
                                .toList();

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Add Supplement'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: remainingSupplements.length,
                                  itemBuilder: (context, index) {
                                    final item = remainingSupplements[index];
                                    return ListTile(
                                      title: Text(item['supplement_name']),
                                      subtitle: Text(
                                        '${item['quantity']} ${item['unit']}',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            selectedSupplements[item['id']] =
                                                TextEditingController(
                                                  text: '0',
                                                );
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Supplement'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final requestData = {
                      "supplements":
                          selectedSupplements.entries
                              .map((entry) {
                                final quantity =
                                    int.tryParse(entry.value.text) ?? 0;
                                if (quantity > 0) {
                                  return {
                                    "id": entry.key,
                                    "quantity": quantity,
                                  };
                                }
                                return null;
                              })
                              .where((item) => item != null)
                              .toList(),
                    };

                    if ((requestData['supplements'] as List).isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please specify quantities for at least one item.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop(); // Close the dialog
                    await _sendRequestInventory(requestData);
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendRequestInventory(Map<String, dynamic> requestData) async {
    try {
      final authService = await AuthService.create();
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token is missing.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.request_supplements),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final message =
            responseData['message'] ?? 'Request created successfully';
        final requestId = responseData['request_id'] ?? 'N/A';
        final requestDate = responseData['request_date'] ?? 'N/A';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$message\nRequest ID: $requestId\nRequest Date: $requestDate',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'An error occurred.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInventoryOverview(),
                      const SizedBox(height: 24),
                      _buildInventoryList(),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showRequestInventoryDialog,
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Request New Inventory'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const InventoryRequestsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history),
                              label: const Text('View Request History'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInventoryOverview() {
    final lowStockCount =
        _inventoryItems
            .where((item) => item['quantity'] >= 0 && item['quantity'] <= 20)
            .length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewCard(
                  'Total Items',
                  _inventoryItems.length.toString(),
                  Icons.inventory_2_outlined,
                ),
                _buildOverviewCard(
                  'Low Stock',
                  lowStockCount.toString(),
                  Icons.warning_amber_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildInventoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inventory Items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _inventoryItems.length,
          itemBuilder: (context, index) {
            final item = _inventoryItems[index];
            final isLowStock = item['quantity'] >= 0 && item['quantity'] <= 20;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.medical_services_outlined,
                  color:
                      isLowStock
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                ),
                title: Text(item['supplement_name']),
                subtitle: Text(
                  '${item['quantity']} ${item['unit']}',
                  style: TextStyle(color: isLowStock ? Colors.orange : null),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
