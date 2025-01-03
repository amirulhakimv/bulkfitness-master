import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({Key? key}) : super(key: key);

  @override
  State<SettingTheme> createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  String selectedTheme = 'Dark';

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
              'Theme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildThemeOption('Light'),
            _buildThemeOption('Dark'),
            _buildThemeOption('System'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    return RadioListTile(
      title: Text(
        theme,
        style: const TextStyle(color: Colors.white),
      ),
      value: theme,
      groupValue: selectedTheme,
      onChanged: (value) {
        setState(() {
          selectedTheme = value.toString();
        });
      },
      activeColor: Colors.white,
    );
  }
}