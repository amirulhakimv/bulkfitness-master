import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/containerTextWidget.dart';
import '../../components/customText.dart';
import '../../components/my_appbar.dart';
import '../../utils/constants.dart';
import 'week1_challenge_screen.dart';
import 'week2_challenge_screen.dart';
import 'week3_challenge_screen.dart';
import 'week4_challenge_screen.dart';

class DailyTasksTabBarScreen extends StatefulWidget {
  const DailyTasksTabBarScreen({super.key});

  @override
  State<DailyTasksTabBarScreen> createState() => _DailyTasksTabBarScreenState();
}

class _DailyTasksTabBarScreenState extends State<DailyTasksTabBarScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();
  double progress = 0.0;
  List<bool> weekChecked = [false, false, false, false];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('progress').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        progress = (data['progress'] ?? 0.0).toDouble();
        weekChecked = List<bool>.from(data['weekChecked'] ?? [false, false, false, false]);
      });
    }
  }

  Future<void> _saveProgress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('progress').doc(user.uid).set({
      'progress': progress,
      'weekChecked': weekChecked,
    });
  }

  void _updateProgress() async {
    double newProgress = 0.0;
    for (var isChecked in weekChecked) {
      if (isChecked) newProgress += 0.25;
    }
    setState(() {
      progress = newProgress;
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('progress').doc(user.uid).set({
        'progress': progress,
        'weekChecked': weekChecked,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(),
      body: Padding(
        padding: EdgeInsets.all(responsive(15, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1st Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive(15, context),
                vertical: responsive(20, context),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsive(12, context)),
                color: Colors.white10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: responsive(12, context)),
                        padding: EdgeInsets.all(responsive(12, context)),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sports_gymnastics,
                          color: Colors.white,
                          size: responsive(40, context),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: '4 Weeks Strength Program',
                            color: Colors.white,
                            fontSize: responsive(17, context),
                            weight: FontWeight.w500,
                          ),
                          CustomText(
                            text: 'Intermediate Level',
                            color: Colors.grey,
                            fontSize: responsive(15, context),
                            weight: FontWeight.w400,
                          ),
                        ],
                      )
                    ],
                  ),
                  const Row(
                    children: [
                      ContainerTextWidget(text: '3x/week'),
                      ContainerTextWidget(text: '45 min/ session'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: responsive(30, context), bottom: responsive(10, context)),
                    child: Row(
                      children: [
                        CustomText(
                          text: 'Progress',
                          color: Colors.white,
                          fontSize: responsive(16, context),
                          weight: FontWeight.w400,
                        ),
                        const Spacer(),
                        CustomText(
                          text: '${(progress * 100).toInt()}%',
                          color: Colors.white,
                          fontSize: responsive(16, context),
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white54,
                    value: progress,
                    minHeight: responsive(7, context),
                    borderRadius: BorderRadius.circular(responsive(20, context)),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: responsive(18, context)),
              child: Align(
                alignment: Alignment.topLeft,
                child: CustomText(
                  text: 'Weekly Overview',
                  color: Colors.white,
                  fontSize: responsive(18, context),
                  weight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: responsive(16, context)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildButtons(0, 'Week 1', 'Foundation & \nEndurance'),
                    _buildButtons(1, 'Week 2', 'Increase \nIntensity'),
                    _buildButtons(2, 'Week 3', 'Adding \nVariety'),
                    _buildButtons(3, 'Week 4', 'Push Maximum Endurance'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    selectedIndex = page;
                  });
                },
                children: const [
                  Week1ChallengeScreen(),
                  Week2ChallengeScreen(),
                  Week3ChallengeScreen(),
                  Week4ChallengeScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(int index, String name, String subTitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        });
      },
      child: Column(
        children: [
          Container(
            width: responsive(135, context),
            height: responsive(100, context),
            padding: EdgeInsets.symmetric(horizontal: responsive(16, context), vertical: responsive(10, context)),
            margin: EdgeInsets.symmetric(horizontal: responsive(5, context)),
            decoration: BoxDecoration(
              color: selectedIndex == index ? Colors.white54 : Colors.white24,
              borderRadius: BorderRadius.circular(responsive(5, context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: name,
                      color: Colors.white,
                      fontSize: responsive(17, context),
                      weight: FontWeight.w500,
                    ),
                    Spacer(),
                    SizedBox(
                      width: responsive(16, context),
                      height: responsive(16, context),
                      child: Checkbox(
                        value: weekChecked[index],
                        onChanged: (bool? value) {
                          setState(() {
                            weekChecked[index] = value!;
                            _updateProgress(); // Update progress after checking/unchecking
                          });
                        },
                        shape: const CircleBorder(),
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive(12, context)),
                CustomText(
                  text: subTitle,
                  color: Colors.white.withOpacity(0.7),
                  fontSize: responsive(13, context),
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
