import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class InventoryRequestsScreen extends StatefulWidget {
  const InventoryRequestsScreen({super.key});

  @override
  State<InventoryRequestsScreen> createState() =>
      _InventoryRequestsScreenState();
}

class _InventoryRequestsScreenState extends State<InventoryRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
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
        Uri.parse(ApiConfig.all_supplement_requests),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _requests = data['supplement_requests'] ?? [];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch requests: ${response.statusCode}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Requests')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? const Center(child: Text('No requests found.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final requestDate = DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(DateTime.parse(request['request_date']));
                  final supplements = request['supplements'] as List;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request ID: ${request['id']}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Request Date: $requestDate'),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${request['status']}',
                            style: TextStyle(
                              color:
                                  request['status'] == 'Approved'
                                      ? Colors.green
                                      : request['status'] == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Supplements:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...supplements.map((supplement) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(supplement['name']),
                                  Text('${supplement['quantity']} units'),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
