import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class SettingFaqs extends StatelessWidget {
  const SettingFaqs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FAQs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildFAQItem(
                    'How do I track my workouts?',
                    'You can track your workouts by going to the Workouts tab and clicking on "Start Workout".',
                  ),
                  _buildFAQItem(
                    'How do I change my password?',
                    'Go to Settings > Account > Change Password to update your password.',
                  ),
                  _buildFAQItem(
                    'Can I share my workouts?',
                    'Yes! After completing a workout, you\'ll see a share button that allows you to post to social media.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(color: Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
    );
  }
}
