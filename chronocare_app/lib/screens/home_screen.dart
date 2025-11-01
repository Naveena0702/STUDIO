import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'mood_tracker_screen.dart';
import 'profile_setup_screen.dart';
import 'medical_records_screen.dart';
import 'notifications_screen.dart';
import 'ai_symptom_checker_page.dart';
import 'journal_page.dart';
import 'diet_page.dart';
import 'water_alarm_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ChronoCare'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.apps), text: 'Features'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const DashboardScreen(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          'Mood Tracker',
                          Icons.sentiment_satisfied,
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'AI Symptom Checker',
                          Icons.psychology,
                          Colors.indigo,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AISymptomCheckerPage()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'Journal',
                          Icons.book,
                          Colors.green,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JournalPage()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'Diet & AI Plans',
                          Icons.restaurant,
                          Colors.orange,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DietPage()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'Water Tracker',
                          Icons.water_drop,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WaterAlarmPage()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'Medical Records',
                          Icons.folder,
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MedicalRecordsScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'AI Insights',
                          Icons.notifications,
                          Colors.amber,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          'Profile Setup',
                          Icons.person,
                          Colors.cyan,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

