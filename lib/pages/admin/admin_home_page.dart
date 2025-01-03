import 'package:bulkfitness/pages/admin/admin_exercise_page.dart';
import 'package:flutter/material.dart';
import '../../components/my_appbar.dart';
import 'add_exercise_page.dart';
import 'add_food_page.dart';
import 'admin_foods_page.dart';
import 'add_challenge_page.dart';
import 'admin_challenges_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showlogoutButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildDashboardItem(
                      context,
                      'Add New Exercise',
                      Icons.fitness_center,
                      Colors.blue,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExercisePage())),
                    ),
                    _buildDashboardItem(
                      context,
                      'View All Exercises',
                      Icons.list,
                      Colors.green,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminExercisesPage())),
                    ),
                    _buildDashboardItem(
                      context,
                      'Add New Food',
                      Icons.restaurant_menu,
                      Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFoodPage())),
                    ),
                    _buildDashboardItem(
                      context,
                      'View All Foods',
                      Icons.fastfood,
                      Colors.purple,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFoodsPage())),
                    ),
                    _buildDashboardItem(
                      context,
                      'Add New Challenge',
                      Icons.emoji_events,
                      Colors.red,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddChallengePage())),
                    ),
                    _buildDashboardItem(
                      context,
                      'View All Challenges',
                      Icons.leaderboard,
                      Colors.teal,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminChallengesPage())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

