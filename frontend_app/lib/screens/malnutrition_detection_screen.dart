import 'package:flutter/material.dart';
import 'child_malnutrition_screen.dart';
class MalnutritionDetectionScreen extends StatefulWidget {
  const MalnutritionDetectionScreen({super.key});

  @override
  State<MalnutritionDetectionScreen> createState() => _MalnutritionDetectionScreenState();
}

class _MalnutritionDetectionScreenState extends State<MalnutritionDetectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _muacController = TextEditingController();
  final String _nutritionalStatus = '';
  String? _selectedChildId;

  final List<Map<String, dynamic>> _children = [
    {
      'id': '1',
      'name': 'John Doe',
      'dateOfBirth': '2022-01-01',
      'gender': 'Male',
      'measurements': []
    },
    // Add more sample data as needed
  ];
  List<Map<String, dynamic>> _filteredChildren = [];

  @override
  void initState() {
    super.initState();
    _filteredChildren = _children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malnutrition Detection'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search children...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredChildren = _children
                      .where((child) =>
                          child['name'].toString().toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _searchController.text.isEmpty
                        ? _children.length
                        : _filteredChildren.length,
                    itemBuilder: (context, index) {
                      final child = _searchController.text.isEmpty
                          ? _children[index]
                          : _filteredChildren[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            child['name'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DoB: ${child['dateOfBirth']}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gender: ${child["gender"]}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (child['measurements'].isNotEmpty) ...[                                  
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last Status: ${child["measurements"].last["status"]}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildMalnutritionScreen(
                                  childData: child,
                                ),
                              ),
                            ).then((value) {
                              // Refresh the list when returning from ChildMalnutritionScreen
                              setState(() {});
                            });
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














