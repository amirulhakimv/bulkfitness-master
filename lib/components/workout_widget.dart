import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'customText.dart';

class WorkoutWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String image;
  const WorkoutWidget({super.key, required this.title, required this.subTitle, required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: responsive(12, context), top: responsive(20, context)),
          width: responsive(80, context),
          height: responsive(75, context),
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(responsive(6, context))),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: title,
              color: Colors.white,
              fontSize: responsive(14, context),
              weight: FontWeight.w500,
            ),
            CustomText(
              text: subTitle,
              color: Colors.grey,
              fontSize: responsive(13, context),
              weight: FontWeight.w400,
            ),
          ],
        )
      ],
    );
  }
}
