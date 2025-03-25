import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class ChildMalnutritionScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ChildMalnutritionScreen({super.key, required this.childData});

  @override
  State<ChildMalnutritionScreen> createState() =>
      _ChildMalnutritionScreenState();
}

class _ChildMalnutritionScreenState extends State<ChildMalnutritionScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _muacController = TextEditingController();
  final TextEditingController _mealFrequencyController =
      TextEditingController();

  final Map<String, Map<String, dynamic>> _foodIntake = {
    "Food Intake": {
      "items": <String>[],
      "selectedItems": <String>[],
      "values": <String, double>{},
      "unit": "grams",
      "quantity": 0.0,
    },
  };

  List<Map<String, String>> _foods = [];
  String? _selectedFood;
  bool _isLoadingFoods = true;
  late final AuthService _authService;

  final List<String> _dietCategories = [
    'Vegetables',
    'Fruits',
    'Proteins',
    'Grains',
    'Dairy',
  ];
  final List<String> _selectedDietCategories = [
    'Vegetables',
  ]; // Default selection

  @override
  void initState() {
    super.initState();
    _initializeAndFetchFoods();
    if (_selectedIllnesses.isEmpty) {
      _selectedIllnesses.add('None'); // Ensure "None" is selected by default
    }
  }

  Future<void> _initializeAndFetchFoods() async {
    _authService = await AuthService.create();
    await _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('Token is missing or empty');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getfood),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['foods'] != null && data['foods'] is List) {
          setState(() {
            _foods =
                (data['foods'] as List).map((food) {
                  return {
                    'english': food['Food Item (English)'].toString(),
                    'hindi': food['Food Item (Hindi)'].toString(),
                  };
                }).toList();
            _isLoadingFoods = false;
          });
        } else {
          debugPrint('Unexpected response format: ${response.body}');
          setState(() {
            _isLoadingFoods = false;
          });
        }
      } else {
        debugPrint('Failed to fetch foods: ${response.body}');
        setState(() {
          _isLoadingFoods = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching foods: $e');
      setState(() {
        _isLoadingFoods = false;
      });
    }
  }

  final int _dietaryDiversityScore = 4;
  bool _hasCleanWater = true;
  final List<String> _selectedIllnesses = [];
  String _nutritionalStatus = '';

  final List<String> _illnessList = [
    'Diarrhea',
    'Respiratory Infections',
    'Delayed Growth and Development',
    'Skin Infections',
    'Rickets',
    'Scurvy',
  ];

  bool _isSubmitting = false; // Track submission state
  String? _errorMessage; // Store error message

  void _submitData() async {
    String? errorMessage;

    // Validate fields
    if (_heightController.text.isEmpty ||
        double.tryParse(_heightController.text) == null) {
      errorMessage = 'Please enter a valid height.';
    } else if (_weightController.text.isEmpty ||
        double.tryParse(_weightController.text) == null) {
      errorMessage = 'Please enter a valid weight.';
    } else if (_muacController.text.isEmpty ||
        double.tryParse(_muacController.text) == null) {
      errorMessage = 'Please enter a valid Mid-Upper Arm Circumference.';
    } else if (_mealFrequencyController.text.isEmpty ||
        int.tryParse(_mealFrequencyController.text) == null ||
        int.parse(_mealFrequencyController.text) > 6) {
      errorMessage = 'Meal Frequency must be a number between 1 and 6.';
    } else if (_foodIntake['Food Intake']?['selectedItems']?.isEmpty ?? true) {
      errorMessage = 'Please select at least one food item.';
    }

    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return;
    }

    final foodIntake = Map<String, double>.from(
      _foodIntake['Food Intake']?['values'] ?? {},
    );

    final childData = {
      "Weight": double.parse(_weightController.text),
      "Height": double.parse(_heightController.text),
      "MUAC": double.parse(_muacController.text),
      "Meal_Frequency": int.parse(_mealFrequencyController.text),
      "Dietary_Diversity_Score": _selectedDietCategories.length,
      "Clean_Water": _hasCleanWater,
      "Illness":
          _selectedIllnesses.contains('None')
              ? ['None']
              : List<String>.from(_selectedIllnesses),
    };

    final requestData = {"food_intake": foodIntake, "child_data": childData};
   
    final childId = widget.childData['id'];
    if (childId == null) {
      setState(() {
        _errorMessage = 'Child ID is missing.';
      });
      return;
    }

    final url = '${ApiConfig.check_mal}$childId';
    print(url);

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = 'Authentication token is missing.';
        });
        return;
      }

      setState(() {
        _isSubmitting = true; // Show loader
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      setState(() {
        _isSubmitting = false; // Hide loader
      });

      if (response.statusCode == 200) {
        print(response.body);
        final responseData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(childData: responseData),
          ),
        );
      } else {
        print(response.body);
        final errorMessage =
            json.decode(response.body)['message'] ?? 'An error occurred.';
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false; // Hide loader
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detect Malnutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ReportScreen(childData: widget.childData),
                ),
              );
            },
            tooltip: 'View Report',
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSubmitting, // Disable interaction during submission
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildMeasurementForm(),
                  const SizedBox(height: 24),
                  _buildDietDiversitySection(),
                  const SizedBox(height: 24),
                  _buildFoodIntakeSection(),
                  const SizedBox(height: 24),
                  _buildHealthSection(),
                  const SizedBox(height: 24),
                  _buildIllnessSection(),
                  const SizedBox(height: 24),
                  Center(
                    child: AnimatedSubmitButton(
                      onPressed: _submitData,
                      label: 'Submit',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5), // Dim background
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Center(
              child: AlertDialog(
                title: const Text('Error'),
                content: Text(_errorMessage!),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null; // Clear error message
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
        ],
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
            Text('Name: ${widget.childData['full_name']}'),
            Text('Date of Birth: ${widget.childData['birth_date']}'),

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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mealFrequencyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meal Frequency (Max: 6)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
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
            Text('Food Intake', style: Theme.of(context).textTheme.titleLarge),
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
                    items:
                        _foods.map<DropdownMenuItem<Map<String, String>>>((
                          food,
                        ) {
                          String foodName = food['english'] ?? '';
                          bool isSelected =
                              _foodIntake['Food Intake']?['selectedItems']
                                  ?.contains(foodName) ??
                              false;

                          return DropdownMenuItem<Map<String, String>>(
                            value: food,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked ?? false) {
                                        _foodIntake['Food Intake']?['selectedItems']
                                            .add(foodName);
                                        _foodIntake['Food Intake']?['values'][foodName] =
                                            0.0; // Default quantity
                                      } else {
                                        _foodIntake['Food Intake']?['selectedItems']
                                            .remove(foodName);
                                        _foodIntake['Food Intake']?['values']
                                            .remove(foodName);
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    '${food['english']} (${food['hindi']})',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  // Display selected items with quantity input
                  ..._foodIntake['Food Intake']?['selectedItems']?.map((
                        foodName,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(child: Text(foodName)),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Qty (grams)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _foodIntake['Food Intake']?['values'][foodName] =
                                          double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList() ??
                      [],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietDiversitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Diversity Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children:
                  _dietCategories.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: _selectedDietCategories.contains(category),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDietCategories.add(category);
                          } else {
                            _selectedDietCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
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
              children:
                  ['None', ..._illnessList].map((illness) {
                    return FilterChip(
                      label: Text(illness),
                      selected: _selectedIllnesses.contains(illness),
                      onSelected: (selected) {
                        setState(() {
                          if (illness == 'None') {
                            _selectedIllnesses.clear();
                            if (selected) {
                              _selectedIllnesses.add('None');
                            }
                          } else {
                            _selectedIllnesses.remove('None');
                            if (selected) {
                              _selectedIllnesses.add(illness);
                            } else if (_selectedIllnesses.isEmpty) {
                              _selectedIllnesses.add('None');
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
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
      'foodIntake': Map<String, double>.from(
        _foodIntake['Food Intake']?['values'] ?? {},
      ),
      'dietaryDiversityScore': _dietaryDiversityScore,
      'hasCleanWater': _hasCleanWater,
      'illnesses': List<String>.from(_selectedIllnesses),
    };

    setState(() {
      widget.childData['measurements'] ??= [];
      widget.childData['measurements'].add(measurement);
      _heightController.clear();
      _weightController.clear();
      _muacController.clear();
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

class AnimatedSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const AnimatedSubmitButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  _AnimatedSubmitButtonState createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
