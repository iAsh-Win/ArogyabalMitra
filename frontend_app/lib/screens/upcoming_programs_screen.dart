import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class UpcomingProgramsScreen extends StatefulWidget {
  const UpcomingProgramsScreen({super.key});

  @override
  State<UpcomingProgramsScreen> createState() => _UpcomingProgramsScreenState();
}

class _UpcomingProgramsScreenState extends State<UpcomingProgramsScreen> {
  late final AuthService _authService;
  List<dynamic> programs = [];
  List<dynamic> filteredPrograms = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndFetchPrograms();
    _searchController.addListener(_filterPrograms);
  }

  Future<void> _initializeAndFetchPrograms() async {
    _authService = await AuthService.create(); // Initialize AuthService
    await _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.get_program), // Use the URL from the config
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['programs'] is List) {
          setState(() {
            programs = data['programs'];
            filteredPrograms = programs;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch programs');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching programs: $e');
    }
  }

  void _filterPrograms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPrograms =
          programs
              .where(
                (program) =>
                    (program['title'] ?? '').toLowerCase().contains(query) ||
                    (program['description'] ?? '').toLowerCase().contains(
                      query,
                    ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search programs...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        filteredPrograms.isEmpty
                            ? const Center(child: Text('No programs found'))
                            : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: filteredPrograms.length,
                              itemBuilder: (context, index) {
                                final program = filteredPrograms[index];
                                final programDate = DateTime.parse(
                                  program['date'],
                                );
                                final isUpcoming = programDate.isAfter(
                                  DateTime.now(),
                                );

                                return Card(
                                  color:
                                      isUpcoming
                                          ? Colors.green.shade50
                                          : Colors.grey.shade200,
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: ListTile(
                                    leading: Icon(
                                      isUpcoming
                                          ? Icons.event_available
                                          : Icons.event_busy,
                                      color:
                                          isUpcoming
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    title: Text(
                                      program['title'] ?? 'No Title',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isUpcoming
                                                ? Colors.green
                                                : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${program['description'] ?? 'No Description'}\n'
                                      'Date: ${program['date'] ?? 'Unknown'}\n'
                                      'Created By: ${program['created_by']['full_name'] ?? 'Unknown'} '
                                      '(${program['created_by']['designation'] ?? 'Unknown'})',
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
