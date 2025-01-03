import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class SettingAbout extends StatelessWidget {
  const SettingAbout({Key? key}) : super(key: key);

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
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BulkFitness is your personal fitness companion designed to help you achieve your fitness goals.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildAboutOption(
              'Terms of Service',
              Icons.description,
                  () {
                // Add terms of service functionality
              },
            ),
            _buildAboutOption(
              'Privacy Policy',
              Icons.privacy_tip,
                  () {
                // Add privacy policy functionality
              },
            ),
            _buildAboutOption(
              'Contact Us',
              Icons.email,
                  () {
                // Add contact functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutOption(
      String label,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}