import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'report_screen.dart';
import 'child_reports_screen.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _children = [];
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
          _children = List<Map<String, dynamic>>.from(data['children']);
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
                (child) =>
                    child['full_name'] != null &&
                    child['full_name'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  void _fetchAndNavigateToReports(String childId) async {
    try {
      final token = await _authService.getToken();
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
        Uri.parse('${ApiConfig.get_child_reports}$childId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      setState(() {
        _isLoading = false; // Hide loader
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildReportsScreen(reports: reports),
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
      setState(() {
        _isLoading = false; // Hide loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Children List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChildren,
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredChildren.isEmpty
                    ? const Center(child: Text('No children found.'))
                    : ListView.builder(
                      itemCount: _filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = _filteredChildren[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(child['full_name'][0]),
                            ),
                            title: Text(child['full_name']),
                            subtitle: Text(
                              'Date of Birth: ${child['birth_date']} • Gender: ${child['gender']}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              _fetchAndNavigateToReports(child['id']);
                            },
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
