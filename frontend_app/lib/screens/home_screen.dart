import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'children_registration_screen.dart';
import 'inventory_management_screen.dart';
import 'malnutrition_detection_screen.dart';
import '../services/auth_service.dart';
import 'children_list_screen.dart';
import 'vaccination_recommendation_screen.dart';
import 'upcoming_programs_screen.dart'; // Import the new screen
import 'all_children_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _todayRegistered = 0;
  late final AuthService _authService;
  Map<String, dynamic> _homeData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchHomeData();
  }

  Future<void> _initializeAndFetchHomeData() async {
    await _initializeAuthService(); // Ensure _authService is initialized
    await _fetchHomeData(); // Fetch home data after initialization
  }

  Future<void> _initializeAuthService() async {
    _authService = await AuthService.create(); // Initialize AuthService
  }

  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.home_data), // Use the URL from the config
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _homeData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch home data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching home data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: const Text('AarogyaBalmitra AI'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage(
                'assets/images/default_profile.png',
              ),
              onBackgroundImageError: (_, __) {
                // Fallback to a placeholder image if the asset is missing
                debugPrint('Error loading profile image');
              },
            ),
            onPressed: () {
              final user = _homeData['anganwadi_user'] ?? {};
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: const AssetImage(
                              'assets/images/default_profile.png',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user['full_name'] ?? 'Unknown User',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          _buildProfileInfoRow(
                            context,
                            icon: Icons.location_on_outlined,
                            label: 'Center Name',
                            value: user['center_name'] ?? 'Unknown Center',
                          ),
                          _buildProfileInfoRow(
                            context,
                            icon: Icons.home_outlined,
                            label: 'Village',
                            value: user['village'] ?? 'Unknown Village',
                          ),
                          _buildProfileInfoRow(
                            context,
                            icon: Icons.location_city_outlined,
                            label: 'District',
                            value: user['district'] ?? 'Unknown District',
                          ),
                          _buildProfileInfoRow(
                            context,
                            icon: Icons.map_outlined,
                            label: 'State',
                            value: user['state'] ?? 'Unknown State',
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await _authService
                    .logout(); // Call the logout method from AuthService
                if (!mounted) return; // Ensure the widget is still mounted
                // Defer navigation to the next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                });
              } catch (e) {
                debugPrint('Error during logout: $e');
                // Optionally, show an error dialog if logout fails
                if (!mounted) return; // Ensure the widget is still mounted
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Logout Failed'),
                        content: const Text(
                          'An error occurred while logging out. Please try again.',
                        ),
                        actions: [  
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                      _buildStatisticsOverview(context),
                      const SizedBox(height: 32),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureGrid(context),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildUserInfo() {
    final user = _homeData['anganwadi_user'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Namaste, ${user['full_name'] ?? 'User'}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user['center_name'] ?? 'Anganwadi Center'}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoRow(
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

  Widget _buildStatisticsOverview(BuildContext context) {
    final statistics = _homeData['statistics'] ?? {};
    final malnutritionStatus = statistics['malnutrition_status'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                context,
                'Total Children',
                '${statistics['total_children'] ?? 0}',
                Icons.child_care_outlined,
              ),
              _buildStatCard(
                context,
                'Low Stock',
                '${statistics['low_stock_supplements']?.length ?? 0}',
                Icons.inventory_outlined,
              ),
              _buildStatCard(
                context,
                'Upcoming Programs',
                '${statistics['upcoming_programs'] ?? 0}',
                Icons.calendar_today_outlined,
              ),
              _buildStatCard(
                context,
                'Normal',
                '${malnutritionStatus['normal'] ?? 0}',
                Icons.check_circle_outline,
              ),
              _buildStatCard(
                context,
                'Moderate Malnutrition',
                '${malnutritionStatus['moderate'] ?? 0}',
                Icons.warning_amber_outlined,
              ),
              _buildStatCard(
                context,
                'Severe Malnutrition',
                '${malnutritionStatus['severe'] ?? 0}',
                Icons.warning_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8), // Ensure this is meaningful
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          'Children Registration',
          Icons.app_registration,
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChildrenRegistrationScreen(),
              ),
            );
            if (result == true) {
              setState(() {
                _todayRegistered++;
              });
            }
          },
        ),
        _buildFeatureCard(
          context,
          'Upcoming Programs',
          Icons.calendar_month_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        const UpcomingProgramsScreen(), // Navigate to the new screen
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'Inventory Management',
          Icons.inventory_2_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InventoryManagementScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'Malnutrition Detection',
          Icons.monitor_heart_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MalnutritionDetectionScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'Health Reports',
          Icons.assessment_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChildrenListScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'Vaccination Recommendation',
          Icons.recommend_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VaccinationRecommendationScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(context, 'All Children', Icons.people_outline, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      const AllChildrenScreen(), // Navigate to the new screen
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12), // Ensure this is meaningful
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
