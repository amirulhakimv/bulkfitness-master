import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class SettingAccount extends StatelessWidget {
  const SettingAccount({Key? key}) : super(key: key);

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
              'Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildAccountOption(
              'Change Password',
              Icons.lock,
                  () {
                // Add change password functionality
              },
            ),
            _buildAccountOption(
              'Privacy Settings',
              Icons.privacy_tip,
                  () {
                // Add privacy settings functionality
              },
            ),
            _buildAccountOption(
              'Delete Account',
              Icons.delete,
                  () {
                // Add delete account functionality
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
      String label,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}