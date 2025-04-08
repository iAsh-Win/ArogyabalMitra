import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart'; // Import the auth service

class Vaccine {
  final String name;
  final String description;
  final String age;

  const Vaccine({
    required this.name,
    required this.description,
    required this.age,
  });
}

class VaccinationRecommendationScreen extends StatefulWidget {
  const VaccinationRecommendationScreen({super.key});

  @override
  _VaccinationRecommendationScreenState createState() =>
      _VaccinationRecommendationScreenState();
}

class _VaccinationRecommendationScreenState
    extends State<VaccinationRecommendationScreen> {
  AuthService? _authService; // Declare AuthService as nullable
  List<dynamic> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeAuthService();
  }

  Future<void> initializeAuthService() async {
    _authService = await AuthService.create(); // Initialize AuthService
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    if (_authService == null) return; // Ensure AuthService is initialized

    setState(() {
      isLoading = true;
    });

    try {
      final token =
          await _authService!.getToken(); // Use the instance to call getToken
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getChildren),
        headers: {
          'Authorization': 'Bearer $token', // Add token to headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['children'] is List) {
          setState(() {
            children = data['children']; // Extract the list of children
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load children');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching children: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Recommendations')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(child['full_name'] ?? 'No Name'),
                        subtitle: Text(
                          'Gender: ${child['gender'] ?? 'Unknown'}\nAge: ${_calculateAge(child['birth_date'])}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChildVaccinationDetailsScreen(
                                    childData: child,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }

  String _calculateAge(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
    final today = DateTime.now();
    final years = today.year - birthDate.year;
    final months = today.month - birthDate.month + (years * 12);

    if (today.day < birthDate.day) {
      return '${months - 1} months';
    }

    return '$months months';
  }
}

final List<Vaccine> vaccines = const [
  Vaccine(
    name: 'BCG',
    description: 'Protects against tuberculosis.',
    age: 'At birth',
  ),
  Vaccine(
    name: 'Hepatitis B',
    description: 'Prevents hepatitis B infection.',
    age: 'At birth, 6 weeks, 10 weeks, 14 weeks',
  ),
  Vaccine(
    name: 'Oral Polio Vaccine (OPV)',
    description: 'Guards against poliomyelitis.',
    age: 'At birth, 6 weeks, 10 weeks, 14 weeks, 16-24 months booster',
  ),
  Vaccine(
    name: 'Inactivated Polio Vaccine (IPV)',
    description: 'Provides additional protection against poliovirus.',
    age: '6 weeks, 14 weeks',
  ),
  Vaccine(
    name: 'Pentavalent Vaccine (DTP-HepB-Hib)',
    description:
        'Protects against diphtheria, tetanus, pertussis, hepatitis B, and Haemophilus influenzae type b.',
    age: '6 weeks, 10 weeks, 14 weeks',
  ),
  Vaccine(
    name: 'Rotavirus Vaccine',
    description: 'Prevents severe diarrhea caused by rotavirus.',
    age: '6 weeks, 10 weeks, 14 weeks',
  ),
  Vaccine(
    name: 'Pneumococcal Conjugate Vaccine (PCV)',
    description:
        'Prevents pneumococcal infections like pneumonia and meningitis.',
    age: '6 weeks, 14 weeks, 9 months booster',
  ),
  Vaccine(
    name: 'Measles-Rubella (MR)',
    description: 'Protects against measles and rubella.',
    age: '9 months, 16-24 months',
  ),
  Vaccine(
    name: 'Vitamin A Supplementation',
    description: 'Supports immune function and prevents vitamin A deficiency.',
    age: '9 months, every 6 months up to 5 years',
  ),
  Vaccine(
    name: 'DTP Booster',
    description: 'Boosts immunity against diphtheria, tetanus, and pertussis.',
    age: '16-24 months',
  ),
  Vaccine(
    name: 'Typhoid Conjugate Vaccine (TCV)',
    description: 'Prevents typhoid fever.',
    age: '9-12 months, booster at 2 years',
  ),
];

class ChildVaccinationDetailsScreen extends StatelessWidget {
  final dynamic childData;

  const ChildVaccinationDetailsScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(childData['full_name'] ?? 'Child Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildInfo(context),
            const SizedBox(height: 24),
            _buildVaccinationTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfo(BuildContext context) {
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
            const SizedBox(height: 16),
            _buildInfoRow('Name', childData['full_name'] ?? 'Unknown'),
            _buildInfoRow('Gender', childData['gender'] ?? 'Unknown'),
            _buildInfoRow('Age', _calculateAge(childData['birth_date'])),
            _buildInfoRow(
              'Date of Birth',
              childData['birth_date'] ?? 'Unknown',
            ),
            _buildInfoRow(
              'Father\'s Name',
              childData['father_name'] ?? 'Unknown',
            ),
            _buildInfoRow(
              'Mother\'s Name',
              childData['mother_name'] ?? 'Unknown',
            ),
            _buildInfoRow('Village', childData['village'] ?? 'Unknown'),
            _buildInfoRow('District', childData['district'] ?? 'Unknown'),
            _buildInfoRow('State', childData['state'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildVaccinationTimeline(BuildContext context) {
    final int childAgeInWeeks = _calculateAgeInWeeks(childData['birth_date']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccination Timeline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...vaccines.map((vaccine) {
              final status = _getVaccinationStatus(
                vaccine.age,
                childAgeInWeeks,
              );
              return _buildVaccinationItem(
                context,
                vaccine.name,
                vaccine.age,
                status,
                vaccine.description,
              );
            }),
          ],
        ),
      ),
    );
  }

  int _calculateAgeInWeeks(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
    final today = DateTime.now();
    return today.difference(birthDate).inDays ~/ 7;
  }

  String _calculateAge(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
    final today = DateTime.now();
    final years = today.year - birthDate.year;
    final months = today.month - birthDate.month + (years * 12);

    if (today.day < birthDate.day) {
      return '${months - 1} months';
    }

    return '$months months';
  }

  VaccinationStatus _getVaccinationStatus(
    String ageString,
    int currentAgeInWeeks,
  ) {
    if (ageString.contains('At birth')) {
      return currentAgeInWeeks >= 0
          ? VaccinationStatus.completed
          : VaccinationStatus.pending;
    }

    final numbers =
        RegExp(
          r'\d+',
        ).allMatches(ageString).map((m) => int.parse(m.group(0)!)).toList();

    if (ageString.contains('weeks')) {
      final earliestWeek = numbers.reduce((a, b) => a < b ? a : b);
      final latestWeek = numbers.reduce((a, b) => a > b ? a : b);

      if (currentAgeInWeeks >= latestWeek) {
        return VaccinationStatus.completed;
      } else if (currentAgeInWeeks >= earliestWeek) {
        return VaccinationStatus.upcoming;
      }
    } else if (ageString.contains('months')) {
      final earliestMonth = numbers.reduce((a, b) => a < b ? a : b);
      final earliestWeek = earliestMonth * 4;

      if (currentAgeInWeeks >= earliestWeek) {
        return VaccinationStatus.completed;
      } else if (currentAgeInWeeks >= earliestWeek - 4) {
        return VaccinationStatus.upcoming;
      }
    }

    return VaccinationStatus.pending;
  }

  Widget _buildVaccinationItem(
    BuildContext context,
    String name,
    String dueDate,
    VaccinationStatus status,
    String description,
  ) {
    Color getStatusColor() {
      switch (status) {
        case VaccinationStatus.completed:
          return Colors.green;
        case VaccinationStatus.upcoming:
          return Colors.orange;
        case VaccinationStatus.pending:
          return Colors.red; // Red for pending vaccines
      }
    }

    IconData getStatusIcon() {
      switch (status) {
        case VaccinationStatus.completed:
          return Icons.check_circle;
        case VaccinationStatus.upcoming:
          return Icons.warning;
        case VaccinationStatus.pending:
          return Icons.schedule;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(getStatusIcon(), color: getStatusColor()),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Due: $dueDate',
                  style: TextStyle(color: getStatusColor()),
                ),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum VaccinationStatus { completed, upcoming, pending }
