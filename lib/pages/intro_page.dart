import 'package:bulkfitness/pages/auth/signup_page.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 50),
          // logo
          const SafeArea(
            child: Center(
              child: Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 72,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // title
          const Text(
            "BULK",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),

          // background image
          Image.asset('lib/images/splashscreen.png'),

          const SizedBox(height: 20),

          // sign up button using MyButton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyButton(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ),
              ),
              text: "SIGN UP",
            ),
          ),
        ],
      ),
    );
  }
}
