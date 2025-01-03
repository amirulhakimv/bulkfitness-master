import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class SettingNotifications extends StatefulWidget {
  const SettingNotifications({Key? key}) : super(key: key);

  @override
  State<SettingNotifications> createState() => _SettingNotificationsState();
}

class _SettingNotificationsState extends State<SettingNotifications> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool workoutReminders = true;

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
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildNotificationToggle(
              'Push Notifications',
              'Receive push notifications',
              pushNotifications,
                  (value) => setState(() => pushNotifications = value),
            ),
            _buildNotificationToggle(
              'Email Notifications',
              'Receive email updates',
              emailNotifications,
                  (value) => setState(() => emailNotifications = value),
            ),
            _buildNotificationToggle(
              'Workout Reminders',
              'Get reminded about your workouts',
              workoutReminders,
                  (value) => setState(() => workoutReminders = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }
}