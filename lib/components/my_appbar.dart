import 'package:bulkfitness/pages/auth/login_page.dart';
import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton; // Control the back button display
  final bool showSettingButton;
  final bool showlogoutButton;

  const MyAppbar({
    Key? key,
    this.showBackButton = false,
    this.showSettingButton = false,
    this.showlogoutButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Custom height
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white, // Color of the bottom border
            width: 1.0, // Thickness of the border
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Show back button if enabled
            if (showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous page
                  },
                ),
              ),

            if (showlogoutButton)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(), // Navigate to SettingPage
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Centered BULK text and icon
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "BULK",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.white,
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

  @override
  Size get preferredSize => const Size.fromHeight(120); // Custom height
}
