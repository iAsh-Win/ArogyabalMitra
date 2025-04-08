import 'package:flutter/material.dart';
import 'child_malnutrition_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class MalnutritionDetectionScreen extends StatefulWidget {
  const MalnutritionDetectionScreen({super.key});

  @override
  State<MalnutritionDetectionScreen> createState() =>
      _MalnutritionDetectionScreenState();
}

class _MalnutritionDetectionScreenState
    extends State<MalnutritionDetectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _muacController = TextEditingController();
  final String _nutritionalStatus = '';

  String? _selectedChildId;

  List<dynamic> _children = [];

  List<Map<String, dynamic>> _filteredChildren = [];
  bool _isLoading = true;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchChildren();
  }

  Future<void> _initializeAndFetchChildren() async {
    _authService = await AuthService.create();
    await _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        // Handle missing token (e.g., redirect to login)
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getChildren),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _children =
              (data['children'] as List)
                  .map((child) => child as Map<String, dynamic>)
                  .toList();
          _filteredChildren = List<Map<String, dynamic>>.from(_children);
          _isLoading = false;
        });
      } else {
        debugPrint('Failed to fetch children: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching children: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterChildren(String query) {
    setState(() {
      _filteredChildren =
          _children
              .where(
                (child) => (child['full_name']?.toString().toLowerCase() ?? '')
                    .contains(query.toLowerCase()),
              )
              .toList()
              .cast<Map<String, dynamic>>(); // Ensure proper casting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Malnutrition Detection')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChildren, // Call the filter function on input
              decoration: InputDecoration(
                hintText: 'Search children...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registered Children',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredChildren.isEmpty
                          ? const Center(child: Text('No children found.'))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: _filteredChildren.length,
                            itemBuilder: (context, index) {
                              final child = _filteredChildren[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  title: Text(
                                    child['full_name'],
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date of birth: ${child['birth_date']}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Gender: ${child["gender"]}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                ChildMalnutritionScreen(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
