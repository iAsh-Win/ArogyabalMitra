import 'package:flutter/material.dart';

class ChildrenRegistrationScreen extends StatefulWidget {
  const ChildrenRegistrationScreen({super.key});

  @override
  State<ChildrenRegistrationScreen> createState() => _ChildrenRegistrationScreenState();
}

class _ChildrenRegistrationScreenState extends State<ChildrenRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _aadharController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _parentAadharController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'Male';
  String _bloodGroup = 'A+';
  bool _sameAsPermAddress = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _aadharController.dispose();
    _permanentAddressController.dispose();
    _currentAddressController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _guardianNameController.dispose();
    _parentContactController.dispose();
    _parentAadharController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 365 * 5)); // 5 years ago
    final maxDate = now.subtract(const Duration(days: 365)); // 1 year ago

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: minDate,
      lastDate: maxDate,
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        // Calculate age
        final age = now.year - picked.year - 
          (now.month > picked.month || 
          (now.month == picked.month && now.day >= picked.day) ? 0 : 1);
        _ageController.text = age.toString();
      });
    }
  }

  void _handleRegistration() {
    if (_formKey.currentState!.validate()) {
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')),
        );
        return;
      }

      // Create registration data
      final registrationData = {
        'name': _nameController.text,
        'dateOfBirth': _dateOfBirth!.toIso8601String(),
        'age': _ageController.text,
        'gender': _gender,
        'bloodGroup': _bloodGroup,
        'aadharNumber': _aadharController.text,
        'permanentAddress': _permanentAddressController.text,
        'currentAddress': _currentAddressController.text,
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
        'guardianName': _guardianNameController.text,
        'parentContact': _parentContactController.text,
        'parentAadhar': _parentAadharController.text,
        'emergencyContact': _emergencyContactController.text,
        'registrationDate': DateTime.now().toIso8601String(),
      };

      // TODO: Save registration data to database
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );

      // Navigate back to previous screen with registration data
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children Registration'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Enter child\'s full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter child\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _dateOfBirth == null
                              ? 'Select Date of Birth'
                              : 'DoB: ${_dateOfBirth.toString().split(' ')[0]}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Age (Years)',
                          prefixIcon: Icon(Icons.cake),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _gender = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype),
                        ),
                        items: _bloodGroups.map((String group) {
                          return DropdownMenuItem<String>(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _bloodGroup = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aadharController,
                  decoration: const InputDecoration(
                    labelText: 'Aadhar Number (Optional)',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 12) {
                      return 'Aadhar number must be 12 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _permanentAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Permanent Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter permanent address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _sameAsPermAddress,
                      onChanged: (bool? value) {
                        setState(() {
                          _sameAsPermAddress = value ?? false;
                          if (_sameAsPermAddress) {
                            _currentAddressController.text = _permanentAddressController.text;
                          }
                        });
                      },
                    ),
                    const Text('Same as Permanent Address'),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentAddressController,
                  enabled: !_sameAsPermAddress,
                  decoration: const InputDecoration(
                    labelText: 'Current Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Parent/Guardian Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Father\'s Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter father\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Mother\'s Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mother\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _guardianNameController,
                  decoration: const InputDecoration(
                    labelText: 'Guardian\'s Name (if applicable)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentContactController,
                  decoration: const InputDecoration(
                    labelText: 'Parent\'s Contact Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter parent\'s contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentAadharController,
                  decoration: const InputDecoration(
                    labelText: 'Parent\'s Aadhar Number',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 12) {
                      return 'Aadhar number must be 12 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Number',
                    prefixIcon: Icon(Icons.emergency),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter emergency contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Register Child'),
                ),
              ]
            )
          )
        )
              ]
      )
          )
        )
      )
              );
           
  }
}