import 'package:flutter/material.dart';
import 'report_screen.dart';
class ChildMalnutritionScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ChildMalnutritionScreen({super.key, required this.childData});

  @override
  State<ChildMalnutritionScreen> createState() => _ChildMalnutritionScreenState();
}

class _ChildMalnutritionScreenState extends State<ChildMalnutritionScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _muacController = TextEditingController();
  final TextEditingController _mealFrequencyController = TextEditingController();
  
  final Map<String, Map<String, dynamic>> _foodIntake = {
    "Food Intake": {
      "items": <String>[],
      "selectedItems": <String>[],
      "values": <String, double>{},
      "unit": "grams",
      "quantity": 0.0
    }
  };
  
  int _dietaryDiversityScore = 4;
  bool _hasCleanWater = true;
  final List<String> _selectedIllnesses = [];
  String _nutritionalStatus = '';

  final List<String> _illnessList = [
    'Diarrhea',
    'Respiratory Infections',
    'Delayed Growth and Development',
    'Skin Infections',
    'Rickets',
    'Scurvy'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childData['name']}\'s Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(childData: widget.childData),
                ),
              );
            },
            tooltip: 'View Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildMeasurementForm(),
            const SizedBox(height: 24),
            _buildFoodIntakeSection(),
            const SizedBox(height: 24),
            _buildHealthSection(),
            const SizedBox(height: 24),
            _buildIllnessSection()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveMeasurements,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Date of Birth: ${widget.childData['dateOfBirth']}'),
            Text('Gender: ${widget.childData['gender']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical Measurements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _calculateNutritionalStatus(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _calculateNutritionalStatus(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _muacController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Mid-Upper Arm Circumference (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _calculateNutritionalStatus(),
            ),
            if (_nutritionalStatus.isNotEmpty) ...[              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getNutritionalStatusColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getNutritionalStatusIcon(),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: $_nutritionalStatus',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodIntakeSection() {
    // Combine all food items into a single list
    List<Map<String, String>> allFoodItems = [];
    _foodIntake.forEach((category, value) {
      value['items'].forEach((item) {
        allFoodItems.add({
          'name': item,
          'category': category,
          'unit': value['unit'],
        });
      });
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Intake',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<Map<String, String>>(
                    value: null,
                    hint: const Text('Select Food Items'),
                    isExpanded: true,
                    underline: Container(),
                    items: allFoodItems.map<DropdownMenuItem<Map<String, String>>>((item) {
                      String category = item['category'] ?? '';
                      String foodName = item['name'] ?? '';
                      bool isSelected = _foodIntake[category]?['selectedItems']?.contains(foodName) ?? false;
                      
                      return DropdownMenuItem<Map<String, String>>(
                        value: item,
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked ?? false) {
                                    _foodIntake[category]?['selectedItems'].add(foodName);
                                    _foodIntake[category]?['values'][foodName] = _foodIntake[category]?['options'][0];
                                  } else {
                                    _foodIntake[category]?['selectedItems'].remove(foodName);
                                    _foodIntake[category]?['values'].remove(foodName);
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            Expanded(
                              child: Text(foodName),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  // Display selected items with quantity selectors
                  ...allFoodItems.where((item) {
                    String category = item['category'] ?? '';
                    String foodName = item['name'] ?? '';
                    return _foodIntake[category]?['selectedItems']?.contains(foodName) ?? false;
                  }).map((item) {
                    String category = item['category'] ?? '';
                    String foodName = item['name'] ?? '';
                    String unit = item['unit'] ?? '';
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(foodName),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: DropdownButton<dynamic>(
                              value: _foodIntake[category]?['values'][foodName] ?? _foodIntake[category]?['options'][0],
                              items: _foodIntake[category]?['options'].map<DropdownMenuItem<dynamic>>((value) {
                                return DropdownMenuItem<dynamic>(
                                  value: value,
                                  child: Text('$value $unit'),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _foodIntake[category]?['values'][foodName] = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Access to Clean Water'),
              value: _hasCleanWater,
              onChanged: (value) {
                setState(() {
                  _hasCleanWater = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllnessSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Illnesses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _illnessList.map((illness) => FilterChip(
                label: Text(illness),
                selected: _selectedIllnesses.contains(illness),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIllnesses.add(illness);
                    } else {
                      _selectedIllnesses.remove(illness);
                    }
                  });
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }


  void _calculateNutritionalStatus() {
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _muacController.text.isEmpty) {
      setState(() {
        _nutritionalStatus = '';
      });
      return;
    }

    double height = double.parse(_heightController.text);
    double weight = double.parse(_weightController.text);
    double muac = double.parse(_muacController.text);

    // Calculate BMI
    double bmi = weight / ((height / 100) * (height / 100));

    setState(() {
      if (bmi < 16) {
        _nutritionalStatus = 'Severe Malnutrition';
      } else if (bmi < 17) {
        _nutritionalStatus = 'Moderate Malnutrition';
      } else if (bmi < 18.5) {
        _nutritionalStatus = 'Mild Malnutrition';
      } else if (bmi < 25) {
        _nutritionalStatus = 'Normal';
      } else {
        _nutritionalStatus = 'Overweight';
      }
    });
  }

  Color _getNutritionalStatusColor() {
    switch (_nutritionalStatus) {
      case 'Severe Malnutrition':
        return Colors.red;
      case 'Moderate Malnutrition':
        return Colors.orange;
      case 'Mild Malnutrition':
        return Colors.yellow.shade700;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNutritionalStatusIcon() {
    switch (_nutritionalStatus) {
      case 'Severe Malnutrition':
        return Icons.warning;
      case 'Moderate Malnutrition':
        return Icons.warning_amber;
      case 'Mild Malnutrition':
        return Icons.info;
      case 'Normal':
        return Icons.check_circle;
      case 'Overweight':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  void _saveMeasurements() {
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _muacController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all measurements'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final measurement = {
      'date': DateTime.now().toIso8601String(),
      'height': double.parse(_heightController.text),
      'weight': double.parse(_weightController.text),
      'muac': double.parse(_muacController.text),
      'status': _nutritionalStatus,
      'foodIntake': Map<String, double>.from(_foodIntake),
      'dietaryDiversityScore': _dietaryDiversityScore,
      'hasCleanWater': _hasCleanWater,
      'illnesses': List<String>.from(_selectedIllnesses),
    };

    setState(() {
      widget.childData['measurements'].add(measurement);
      _heightController.clear();
      _weightController.clear();      _muacController.clear();
      _mealFrequencyController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurements saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
