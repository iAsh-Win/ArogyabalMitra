import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChildrenRegistrationScreen extends StatefulWidget {
  const ChildrenRegistrationScreen({super.key});

  @override
  State<ChildrenRegistrationScreen> createState() => _ChildrenRegistrationScreenState();
}

class _ChildrenRegistrationScreenState extends State<ChildrenRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  bool _isLoading = false;

  // Controllers for all fields
  final _fullNameController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _villageController = TextEditingController();
  final _societyNameController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _fatherContactController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _parentAadhaarNumberController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _initializeAuthService();
    _checkAuthStatus();
  }

  Future<void> _initializeAuthService() async {
    _authService = await AuthService.create();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _authService.getToken();
      if (!mounted) return;

      if (token == null || token.isEmpty) {
        // No token or empty token, navigate to login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (!mounted) return;
      // If there's any error checking token, go to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _aadhaarNumberController.dispose();
    _villageController.dispose();
    _societyNameController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _fatherNameController.dispose();
    _fatherContactController.dispose();
    _motherNameController.dispose();
    _parentAadhaarNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select birth date')),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final token = await _authService.getToken();
        if (token == null || token.isEmpty) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }

        final response = await http.post(
          Uri.parse(ApiConfig.childrenCreate),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'full_name': _fullNameController.text.trim(),
            'birth_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
            'gender': _selectedGender,
            'aadhaar_number': _aadhaarNumberController.text.trim(),
            'village': _villageController.text.trim(),
            'society_name': _societyNameController.text.trim(),
            'district': _districtController.text.trim(),
            'state': _stateController.text.trim(),
            'pin_code': _pinCodeController.text.trim(),
            'father_name': _fatherNameController.text.trim(),
            'father_contact': _fatherContactController.text.trim(),
            'mother_name': _motherNameController.text.trim(),
            'parent_aadhaar_number': _parentAadhaarNumberController.text.trim(),
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Failed to register child');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarNumberController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhaar number';
                  }
                  if (value.length != 12) {
                    return 'Aadhaar number must be 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(
                  labelText: 'Village',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter village';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _societyNameController,
                decoration: const InputDecoration(
                  labelText: 'Society Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter society name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter district';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinCodeController,
                decoration: const InputDecoration(
                  labelText: 'PIN Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN code';
                  }
                  if (value.length != 6) {
                    return 'PIN code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: "Father's Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter father's name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatherContactController,
                decoration: const InputDecoration(
                  labelText: "Father's Contact",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter father's contact";
                  }
                  if (value.length != 10) {
                    return 'Contact number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: "Mother's Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter mother's name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentAadhaarNumberController,
                decoration: const InputDecoration(
                  labelText: "Parent's Aadhaar Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter parent's Aadhaar number";
                  }
                  if (value.length != 12) {
                    return 'Aadhaar number must be 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}