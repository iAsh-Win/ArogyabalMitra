import 'package:flutter/material.dart';
import 'report_screen.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _children = [
    {
      'id': '1',
      'name': 'Rahul Kumar',
      'age': '3 years',
      'gender': 'Male',
      'parent': 'Rajesh Kumar'
    },
    {
      'id': '2',
      'name': 'Priya Singh',
      'age': '2 years',
      'gender': 'Female',
      'parent': 'Amit Singh'
    },
    // Add more sample data as needed
  ];
  List<Map<String, dynamic>> _filteredChildren = [];

  @override
  void initState() {
    super.initState();
    _filteredChildren = _children;
  }

  void _filterChildren(String query) {
    setState(() {
      _filteredChildren = _children
          .where((child) =>
              child['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children List'),
      ),
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
            child: ListView.builder(
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
                      child: Text(child['name'][0]),
                    ),
                    title: Text(child['name']),
                    subtitle: Text('${child['age']} • ${child['gender']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportScreen(
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