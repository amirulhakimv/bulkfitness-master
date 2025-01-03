import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'customText.dart';

class ContainerTextWidget extends StatelessWidget {
  final String text;
  const ContainerTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: responsive(6, context), top: responsive(16, context)),
      padding: EdgeInsets.symmetric(horizontal: responsive(16, context), vertical: responsive(5, context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive(30, context)),
        color: Colors.white24,
      ),
      child: CustomText(
        text: text,
        color: Colors.white,
        fontSize: responsive(12, context),
        weight: FontWeight.w300,
      ),
    );
  }
}
