import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class ReportScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ReportScreen({super.key, required this.childData});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  Map<String, String> selectedQuantities = {};
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final supplements =
        widget.childData['malnutrition_record']?['supplements'] as List? ?? [];
    final hasDistributedSupplements = supplements.any(
      (supplement) =>
          supplement['quantity_distributed'] != null &&
          supplement['distribution_date'] != null,
    );

    setState(() {
      _isLoading = false; // Remove loader
      if (hasDistributedSupplements) {
        _pageController.jumpToPage(1); // Show Distributed Supplements view
      } else {
        _pageController.jumpToPage(0); // Show Prescribed Supplements view
      }
    });
  }

  Future<void> _saveSupplementQuantities() async {
    final childId = widget.childData['child']?['id'];
    if (childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child ID is missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate quantities
    final supplements =
        selectedQuantities.entries
            .where(
              (entry) =>
                  int.tryParse(entry.value) != null &&
                  int.parse(entry.value) > 0,
            )
            .map((entry) {
              final supplement = (widget
                          .childData['malnutrition_record']['supplements']
                      as List)
                  .firstWhere(
                    (s) => s['name'] == entry.key,
                    orElse: () => null,
                  );
              if (supplement != null) {
                return {
                  "supplement_id": supplement['id'],
                  "quantity": int.parse(entry.value),
                };
              }
              return null;
            })
            .where((item) => item != null)
            .toList();

    if (supplements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid quantities for supplements.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final requestData = {"child_id": childId, "supplements": supplements};

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

      setState(() {
        _isLoading = true; // Show loader
      });

      final response = await http.post(
        Uri.parse(ApiConfig.distribute_suppliment),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplement quantities saved successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _reloadScreen(); // Reload the screen
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
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  void _reloadScreen() async {
    final recordId =
        widget.childData['malnutrition_record_id'] ??
        widget.childData['child']?['id'];
    if (recordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record ID is missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      setState(() {
        _isLoading = true; // Show loader
      });

      final response = await http.get(
        Uri.parse('${ApiConfig.get_child_report}$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final updatedChildData = json.decode(response.body);
        final supplements =
            updatedChildData['malnutrition_record']?['supplements'] as List? ??
            [];
        final hasDistributedSupplements = supplements.any(
          (supplement) =>
              supplement['quantity_distributed'] != null &&
              supplement['distribution_date'] != null,
        );

        setState(() {
          _isLoading = false; // Hide loader
          if (hasDistributedSupplements) {
            _pageController.jumpToPage(1); // Show Distributed Supplements view
          } else {
            _pageController.jumpToPage(0); // Show Prescribed Supplements view
          }
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(childData: updatedChildData),
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
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = (widget.childData['child'] as Map<String, dynamic>?) ?? {};
    final malnutritionRecord =
        (widget.childData['malnutrition_record'] as Map<String, dynamic>?) ??
        {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${child['full_name']?.toString() ?? 'Child'}\'s Health Report',
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 16),
                  _buildMalnutritionStatus(malnutritionRecord),
                  const SizedBox(height: 16),
                  _buildNutrientDeficiencies(malnutritionRecord),
                  const SizedBox(height: 16),
                  _buildRecommendedFoods(malnutritionRecord),
                  const SizedBox(height: 16),
                  _buildSupplements(malnutritionRecord),
                  const SizedBox(height: 16),
                  _buildGrowthChart(),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement PDF export
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildBasicInfo() {
    final child = (widget.childData['child'] as Map<String, dynamic>?) ?? {};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Child Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', child['full_name']?.toString() ?? 'N/A'),
            _buildInfoRow('Age', '${child['age']?.toString() ?? 'N/A'} months'),
            _buildInfoRow('Gender', child['gender']?.toString() ?? 'N/A'),
            _buildInfoRow(
              'Birth Date',
              child['birth_date']?.toString() ?? 'N/A',
            ),
            _buildInfoRow('ID', child['id']?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildMalnutritionStatus(Map<String, dynamic> record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Malnutrition Assessment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Weight',
              '${record['weight']?.toString() ?? 'N/A'} kg',
            ),
            _buildInfoRow(
              'Height',
              '${record['height']?.toString() ?? 'N/A'} cm',
            ),
            _buildInfoRow('MUAC', '${record['muac']?.toString() ?? 'N/A'} cm'),
            _buildInfoRow(
              'Meal Frequency',
              '${record['meal_frequency']?.toString() ?? 'N/A'} times/day',
            ),
            _buildInfoRow(
              'Dietary Diversity Score',
              record['dietary_diversity_score']?.toString() ?? 'N/A',
            ),
            _buildInfoRow(
              'Clean Water Access',
              record['clean_water'] == true ? 'Yes' : 'No',
            ),
            const SizedBox(height: 8),
            const Text(
              'Z-Scores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildZScores(record['z_scores'] as Map<String, dynamic>? ?? {}),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Predicted Status',
              record['predicted_status']?.toString() ?? 'N/A',
              isHighlighted: true,
            ),
            if (record['illnesses'] != null &&
                (record['illnesses'] as List).isNotEmpty)
              _buildIllnesses(record['illnesses'] as List),
          ],
        ),
      ),
    );
  }

  Widget _buildZScores(Map<String, dynamic> zScores) {
    return Column(
      children: [
        _buildInfoRow(
          'Weight-for-Age (WAZ)',
          (zScores['waz'] ?? 0.0).toStringAsFixed(2),
        ),
        _buildInfoRow(
          'Height-for-Age (HAZ)',
          (zScores['haz'] ?? 0.0).toStringAsFixed(2),
        ),
        _buildInfoRow(
          'Weight-for-Height (WHZ)',
          (zScores['whz'] ?? 0.0).toStringAsFixed(2),
        ),
        _buildInfoRow(
          'MUAC-for-Age',
          (zScores['muac_z'] ?? 0.0).toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildNutrientDeficiencies(Map<String, dynamic> record) {
    final deficiencies = (record['nutrient_deficiencies'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrient Deficiencies',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  deficiencies
                      .map(
                        (deficiency) => Chip(
                          label: Text(deficiency.toString()),
                          backgroundColor: Colors.red[100],
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedFoods(Map<String, dynamic> record) {
    final List<Map<String, String>> defaultFoods = [
      {'item': 'Lentils (Dal)', 'hindi': 'दाल'},
      {'item': 'Green Leafy Vegetables', 'hindi': 'हरी पत्तेदार सब्जियां'},
      {'item': 'Eggs', 'hindi': 'अंडे'},
      {'item': 'Milk', 'hindi': 'दूध'},
      {'item': 'Yogurt', 'hindi': 'दही'},
      {'item': 'Banana', 'hindi': 'केला'},
      {'item': 'Orange', 'hindi': 'संतरा'},
      {'item': 'Ragi', 'hindi': 'रागी'},
      {'item': 'Peanuts', 'hindi': 'मूंगफली'},
      {'item': 'Fish', 'hindi': 'मछली'},
    ];

    final foods =
        (record['recommended_foods'] as List?)
            ?.map((food) => Map<String, String>.from(food as Map))
            .toList() ??
        defaultFoods;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Foods',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(
                      foods[index]['item'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      foods[index]['hindi'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    leading: const Icon(Icons.restaurant_menu, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplements(Map<String, dynamic> record) {
    final supplements = (record['supplements'] as List?) ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                children: [
                  // Prescribed Supplements Page (for entering quantities)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescribed Supplements',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children:
                              supplements
                                  .where(
                                    (supplement) =>
                                        supplement['id'] != null &&
                                        (supplement['quantity_distributed'] ==
                                                null ||
                                            supplement['distribution_date'] ==
                                                null),
                                  )
                                  .map((supplement) {
                                    final supplementName =
                                        supplement['name'] ?? '';
                                    return ListTile(
                                      title: Text(supplementName),
                                      leading: const Icon(Icons.medication),
                                      trailing: SizedBox(
                                        width: 100,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: 'Quantity',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedQuantities[supplementName] =
                                                  value;
                                            });
                                          },
                                          controller: TextEditingController(
                                            text:
                                                selectedQuantities[supplementName] ??
                                                '',
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveSupplementQuantities,
                          child: const Text('Save Quantities'),
                        ),
                      ),
                    ],
                  ),
                  // Distributed Supplements Page
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distributed Supplements',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children:
                              supplements
                                  .where(
                                    (supplement) =>
                                        supplement['quantity_distributed'] !=
                                            null &&
                                        supplement['distribution_date'] != null,
                                  )
                                  .map((supplement) {
                                    final supplementName =
                                        supplement['name'] ?? '';
                                    final quantityDistributed =
                                        supplement['quantity_distributed'] ?? 0;
                                    final distributionDate =
                                        supplement['distribution_date'] ??
                                        'Not yet distributed';

                                    return ListTile(
                                      title: Text(supplementName),
                                      subtitle: Text(
                                        'Last distributed: $distributionDate',
                                      ),
                                      leading: const Icon(
                                        Icons.medication_liquid,
                                      ),
                                      trailing: Text(
                                        '$quantityDistributed units',
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlighted ? Colors.red : null,
                fontWeight: isHighlighted ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllnesses(List illnesses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Current Illnesses:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              illnesses
                  .map(
                    (illness) => Chip(
                      label: Text(illness.toString()),
                      backgroundColor: Colors.orange[100],
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildGrowthChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Measurements',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text('Growth Chart will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
