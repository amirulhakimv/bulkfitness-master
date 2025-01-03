import 'package:bulkfitness/pages/home/slipt_section_screen.dart';
import 'package:bulkfitness/pages/home/workout_split_page.dart';
import 'package:flutter/material.dart';

import '../../components/customText.dart';
import '../../utils/constants.dart';

class MyCreationTabBar extends StatefulWidget {
  const MyCreationTabBar({super.key});

  @override
  State<MyCreationTabBar> createState() => _MyCreationTabBarState();
}

class _MyCreationTabBarState extends State<MyCreationTabBar> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: newAppColors.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: responsive(16, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildButtons(0, 'WorkOut'),
                  _buildButtons(1, 'Splits'),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black12,
            ),
            Expanded(
                child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  selectedIndex = page;
                });
              },
              children: [
                WorkoutSplitPage(),
                SplitSectionScreen(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(int index, String name) {
    return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        child: Column(
          children: [
            CustomText(
              text: name,
              color: selectedIndex == index ? Colors.white : Colors.white,
              fontSize: responsive(16, context),
              weight: FontWeight.w500,
            ),
            selectedIndex == index
                ? Container(
                    width: 75,
                    height: 3,
                    margin: EdgeInsets.only(top: responsive(15, context)),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(responsive(12, context))),
                  )
                : SizedBox(
                    height: responsive(18, context),
                  ),
          ],
        ));
  }
}
