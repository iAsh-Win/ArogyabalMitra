import 'package:flutter/material.dart';

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
  
  Map<String, Map<String, dynamic>> _foodIntake = {
    "Dairy": {
      "Milk": {"value": 0.0, "unit": "ml"},
      "Curd": {"value": 0.0, "unit": "ml"},
      "Buttermilk": {"value": 0.0, "unit": "ml"}
    },
    "Proteins": {
      "Eggs": {"value": 0, "unit": "pieces"},
      "Dal": {"value": 0.0, "unit": "g"},
      "Paneer": {"value": 0.0, "unit": "g"}
    },
    "Vegetables": {
      "Green Leafy": {"value": 0.0, "unit": "g"},
      "Tomatoes": {"value": 0, "unit": "pieces"},
      "Onions": {"value": 0, "unit": "pieces"},
      "Potatoes": {"value": 0, "unit": "pieces"}
    },
    "Fruits": {
      "Banana": {"value": 0, "unit": "pieces"},
      "Apple": {"value": 0, "unit": "pieces"},
      "Orange": {"value": 0, "unit": "pieces"}
    },
    "Grains": {
      "Rice": {"value": 0.0, "unit": "g"},
      "Roti": {"value": 0, "unit": "pieces"},
      "Poha": {"value": 0.0, "unit": "g"}
    }
  };
  
  int _dietaryDiversityScore = 4;
  bool _hasCleanWater = true;
  List<String> _selectedIllnesses = [];
  String _nutritionalStatus = '';

  final List<String> _illnessList = [
    'Diarrhea',
    'Fever',
    'Cough',
    'Cold',
    'Malaria',
    'Pneumonia'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childData['name']}\'s Measurements'),
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
            _buildMeasurementHistory(),
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
            TextField(
              controller: _mealFrequencyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meals per day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dietary Diversity Score: $_dietaryDiversityScore',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _dietaryDiversityScore.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: _dietaryDiversityScore.toString(),
              onChanged: (value) {
                setState(() {
                  _dietaryDiversityScore = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            ..._foodIntake.entries.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category.key,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...category.value.entries.map((food) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(food.key),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixText: food.value['unit'],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          controller: TextEditingController(
                            text: food.value['value'].toString(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _foodIntake[category.key]![food.key]!['value'] = 
                                food.value['unit'] == 'pieces' ? 
                                int.tryParse(value) ?? 0 : 
                                double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            )).toList(),
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
            const SizedBox(height: 16),
            Text(
              'Recent Illnesses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
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

  Widget _buildMeasurementHistory() {
    final measurements = List<Map<String, dynamic>>.from(widget.childData['measurements']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Measurement History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (measurements.isEmpty)
              const Center(
                child: Text('No measurements recorded yet'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        'Date: ${DateTime.parse(measurement['date']).toString().split('.')[0]}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Height: ${measurement['height']} cm'),
                          Text('Weight: ${measurement['weight']} kg'),
                          Text('MUAC: ${measurement['muac']} cm'),
                          Text('Status: ${measurement['status']}'),
                        ],
                      ),
                    ),
                  );
                },
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
