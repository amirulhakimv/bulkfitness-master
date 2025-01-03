import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'customText.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? buttonColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final Color? borderColor;
  final FontWeight? weight;
  final Color? textColor;

  final String? fontFamily;
  final VoidCallback onTap;
  const CustomButton({
    super.key,
    this.buttonColor,
    required this.text,
    this.fontSize,
    this.weight,
    this.textColor,
    required this.onTap,
    this.fontFamily,
    this.borderColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width ?? double.infinity,
            height: height ?? responsive(45, context),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.transparent),
              color: buttonColor,
              borderRadius: BorderRadius.circular(responsive(5, context)),
              //gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgColor1, bgColor2]),
            ),
            child: Center(
              child: CustomText(
                text: text,
                fontSize: fontSize,
                weight: weight,
                color: textColor,
                fontFamily: fontFamily,
              ),
            ),
          ),
          // Positioned(
          //   bottom: -90,
          //   left: responsive(20, context),
          //   child: Image.asset(
          //     'assets/artwork.png',
          //   ),
          // )
        ],
      ),
    );
  }
}

class CustomImageButton extends StatelessWidget {
  final String image;
  final Color? buttonColor;

  final Color? textColor;

  final String? fontFamily;
  final VoidCallback onTap;
  const CustomImageButton({
    super.key,
    this.buttonColor,
    required this.image,
    this.textColor,
    required this.onTap,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: responsive(53, context),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: buttonColor,
              borderRadius: BorderRadius.circular(30),
              //gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgColor1, bgColor2]),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: responsive(120, context),
                height: responsive(30, context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
