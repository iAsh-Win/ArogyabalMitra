import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'report_screen.dart';

class ChildReportsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> reports;

  const ChildReportsScreen({super.key, required this.reports});

  @override
  State<ChildReportsScreen> createState() => _ChildReportsScreenState();
}

class _ChildReportsScreenState extends State<ChildReportsScreen> {
  bool _isLoading = false;

  Future<void> _fetchAndNavigateToReport(String recordId) async {
    try {
      setState(() {
        _isLoading = true; // Show loader
      });

      final authService = await AuthService.create();
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token is missing.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.get_child_report}$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      setState(() {
        _isLoading = false; // Hide loader
      });

      if (response.statusCode == 200) {
        final reportData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(childData: reportData),
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
      appBar: AppBar(title: const Text('Child Reports')),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            widget.reports.isEmpty
                ? const Center(child: Text('No reports available.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: widget.reports.length,
                  itemBuilder: (context, index) {
                    final report = widget.reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          'Report Date: ${DateTime.parse(report['created_at']).toLocal().toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Weight: ${report['weight'] ?? 'N/A'} kg'),
                            Text('Height: ${report['height'] ?? 'N/A'} cm'),
                            Text('MUAC: ${report['muac'] ?? 'N/A'} cm'),
                            Text('Status: ${report['status'] ?? 'N/A'}'),
                            Text(
                              'Predicted Status: ${report['predicted_status'] ?? 'N/A'}',
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final recordId = report['malnutrition_record_id'];
                          if (recordId != null) {
                            _fetchAndNavigateToReport(recordId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Record ID is missing.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
