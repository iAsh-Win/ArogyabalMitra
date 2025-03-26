import 'package:flutter/material.dart';
import 'children_registration_screen.dart';
import 'vaccination_data_screen.dart';
import 'inventory_management_screen.dart';
import 'malnutrition_detection_screen.dart';
import '../services/auth_service.dart';
import 'children_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _todayRegistered = 0;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeAndCheckAuth();
  }

  Future<void> _initializeAndCheckAuth() async {
    await _initializeAuthService(); // Ensure _authService is initialized
    await _checkAuthStatus(); // Check auth status after initialization
  }

  Future<void> _initializeAuthService() async {
    _authService = await AuthService.create(); // Initialize AuthService
  }

  Future<void> _checkAuthStatus() async {
    final token = await _authService.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      // Redirect to login if no token is found
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
    print('Token: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aarogya Balmitra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
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
                            backgroundImage: AssetImage(
                              'assets/images/default_profile.png',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Priya Sharma',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Health Worker',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('priya.sharma@health.gov.in'),
                            dense: true,
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: const Text('Primary Health Center, Delhi'),
                            dense: true,
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
                if (context.mounted) {
                  // Defer navigation to the next frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  });
                }
              } catch (e) {
                debugPrint('Error during logout: $e');
                // Optionally, show an error dialog if logout fails
                if (context.mounted) {
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
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste, Priya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anganwadi Center #123',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildStatisticsOverview(context),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search child records...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildStatisticsOverview(BuildContext context) {
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
                'Registered',
                _todayRegistered.toString(),
                Icons.person_add_outlined,
              ),
              _buildStatCard(
                context,
                'Vaccinated',
                '18',
                Icons.medical_services_outlined,
              ),
              _buildStatCard(
                context,
                'Alerts',
                '3',
                Icons.warning_amber_outlined,
              ),
              _buildStatCard(
                context,
                'Recovered',
                '12',
                Icons.health_and_safety_outlined,
              ),
              _buildStatCard(
                context,
                'Normal',
                '45',
                Icons.child_care_outlined,
              ),
              _buildStatCard(context, 'Malnourished', '8', Icons.sick_outlined),
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
        const SizedBox(height: 8),
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
          'Vaccination Data',
          Icons.calendar_month_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VaccinationDataScreen(),
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
              const SizedBox(height: 12),
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
