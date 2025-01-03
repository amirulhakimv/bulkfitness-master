import 'package:flutter/cupertino.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? weight;
  final Color? color;
  final String? fontFamily;
  final TextDecoration? decoration;
  final Color? underLineColor;
  final TextOverflow? textOverFlow;
  final TextAlign? textAlign;
  const CustomText(
      {super.key,
      required this.text,
      this.fontSize,
      this.weight,
      this.color,
      this.fontFamily,
      this.textAlign,
      this.decoration,
      this.textOverFlow,
      this.underLineColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: textOverFlow,
      style: TextStyle(
        decoration: decoration,
        decorationColor: underLineColor,
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        fontFamily: fontFamily,
        // overflow: TextOverflow.,
      ),
    );
  }
}
