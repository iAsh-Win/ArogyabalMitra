import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ReportScreen({super.key, required this.childData});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, String> selectedQuantities = {};
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final child = (widget.childData['child'] as Map<String, dynamic>?) ?? {};
    final malnutritionRecord = (widget.childData['malnutrition_record'] as Map<String, dynamic>?) ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${child['full_name']?.toString() ?? 'Child'}\'s Health Report'),
      ),
      body: SingleChildScrollView(
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
            _buildInfoRow('Birth Date', child['birth_date']?.toString() ?? 'N/A'),
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
            _buildInfoRow('Weight', '${record['weight']?.toString() ?? 'N/A'} kg'),
            _buildInfoRow('Height', '${record['height']?.toString() ?? 'N/A'} cm'),
            _buildInfoRow('MUAC', '${record['muac']?.toString() ?? 'N/A'} cm'),
            _buildInfoRow('Meal Frequency', '${record['meal_frequency']?.toString() ?? 'N/A'} times/day'),
            _buildInfoRow('Dietary Diversity Score', record['dietary_diversity_score']?.toString() ?? 'N/A'),
            _buildInfoRow('Clean Water Access', record['clean_water'] == true ? 'Yes' : 'No'),
            const SizedBox(height: 8),
            const Text('Z-Scores:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildZScores(record['z_scores'] as Map<String, dynamic>? ?? {}),
            const SizedBox(height: 8),
            _buildInfoRow('Predicted Status', record['predicted_status']?.toString() ?? 'N/A', isHighlighted: true),
            if (record['illnesses'] != null && (record['illnesses'] as List).isNotEmpty)
              _buildIllnesses(record['illnesses'] as List),
          ],
        ),
      ),
    );
  }

  Widget _buildZScores(Map<String, dynamic> zScores) {
    return Column(
      children: [
        _buildInfoRow('Weight-for-Age (WAZ)', (zScores['waz'] ?? 0.0).toStringAsFixed(2)),
        _buildInfoRow('Height-for-Age (HAZ)', (zScores['haz'] ?? 0.0).toStringAsFixed(2)),
        _buildInfoRow('Weight-for-Height (WHZ)', (zScores['whz'] ?? 0.0).toStringAsFixed(2)),
        _buildInfoRow('MUAC-for-Age', (zScores['muac_z'] ?? 0.0).toStringAsFixed(2)),
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
              children: deficiencies.map((deficiency) =>
                Chip(
                  label: Text(deficiency.toString()),
                  backgroundColor: Colors.red[100],
                ),
              ).toList(),
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
      {'item': 'Fish', 'hindi': 'मछली'}
    ];
    final foods = (record['recommended_foods'] as List?)?.map((food) => 
      food as Map<String, String>).toList() ?? defaultFoods;
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
    final supplements = [
      {"name": "Iron-Folic Acid syrup"},
      {"name": "Poshan Sachet (MNP)"},
      {"name": "Balbhog"},
      {"name": "Protein powder"},
      {"name": "Vitamin A syrup"},
      {"name": "Bal Amrit / Bal Shakti"},
      {"name": "DFS Namak"}
    ];
    
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
                  // Prescribed Supplements Page
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescribed Supplements',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: supplements.map((supplement) =>
                            ListTile(
                              title: Text(supplement['name'] ?? ''),
                              leading: const Icon(Icons.medication),
                              trailing: SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Quantity',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedQuantities[supplement['name'] ?? ''] = value;
                                    });
                                  },
                                  controller: TextEditingController(
                                    text: selectedQuantities[supplement['name'] ?? ''] ?? ''
                                  ),
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Map<String, dynamic> supplementData = {
                              'child_id': widget.childData['child']?['id'],
                              'supplements': selectedQuantities
                            };
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Supplement quantities saved')),
                            );
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: supplements.map((supplement) =>
                            ListTile(
                              title: Text(supplement['name'] ?? ''),
                              subtitle: Text('Last distributed: Not yet distributed'),
                              leading: const Icon(Icons.medication_liquid),
                              trailing: Text('0 units'),
                            ),
                          ).toList(),
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

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
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
        Text('Current Illnesses:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: illnesses.map((illness) =>
            Chip(
              label: Text(illness.toString()),
              backgroundColor: Colors.orange[100],
            ),
          ).toList(),
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