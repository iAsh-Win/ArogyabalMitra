import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class AllChildrenScreen extends StatefulWidget {
  const AllChildrenScreen({super.key});

  @override
  State<AllChildrenScreen> createState() => _AllChildrenScreenState();
}

class _AllChildrenScreenState extends State<AllChildrenScreen> {
  late final AuthService _authService;
  List<dynamic> children = [];
  List<dynamic> filteredChildren = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndFetchChildren();
    _searchController.addListener(_filterChildren);
  }

  Future<void> _initializeAndFetchChildren() async {
    _authService = await AuthService.create(); // Initialize AuthService
    await _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getChildren), // Use the URL from the config
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['children'] is List) {
          setState(() {
            children = data['children'];
            filteredChildren = children;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch children');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching children: $e');
    }
  }

  void _filterChildren() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredChildren =
          children
              .where(
                (child) =>
                    (child['full_name'] ?? '').toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Children')),
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
                        hintText: 'Search by name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        filteredChildren.isEmpty
                            ? const Center(child: Text('No children found'))
                            : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: filteredChildren.length,
                              itemBuilder: (context, index) {
                                final child = filteredChildren[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(
                                      child['full_name'] ?? 'Unknown',
                                    ),
                                    subtitle: Text(
                                      'Gender: ${child['gender'] ?? 'Unknown'}\n'
                                      'Village: ${child['village'] ?? 'Unknown'}',
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ChildDetailsScreen(
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
    );
  }
}

class ChildDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> childData;

  const ChildDetailsScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(childData['full_name'] ?? 'Child Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: childData['full_name'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.cake_outlined,
                  label: 'Date of Birth',
                  value: childData['birth_date'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.male_outlined,
                  label: 'Gender',
                  value: childData['gender'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.home_outlined,
                  label: 'Village',
                  value: childData['village'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.location_city_outlined,
                  label: 'District',
                  value: childData['district'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.map_outlined,
                  label: 'State',
                  value: childData['state'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'Father\'s Contact',
                  value: childData['father_contact'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline,
                  label: 'Father\'s Name',
                  value: childData['father_name'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline,
                  label: 'Mother\'s Name',
                  value: childData['mother_name'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.credit_card_outlined,
                  label: 'Aadhaar Number',
                  value: childData['aadhaar_number'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.credit_card_outlined,
                  label: 'Parent Aadhaar Number',
                  value: childData['parent_aadhaar_number'] ?? 'Unknown',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
