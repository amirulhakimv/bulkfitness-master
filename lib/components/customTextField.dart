import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? suffixIcon;

  final int? maxLength;
  final int? maxLine;
  final String? hints;
  final bool obscureText;
  final VoidCallback? toggleEyeIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChange;
  final FormFieldValidator<String>? validator;
  bool? enabled;

  CustomTextField({
    super.key,
    required this.controller,
    this.suffixIcon,
    this.hints,
    this.obscureText = false,
    this.toggleEyeIcon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.maxLine,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLine ?? 1,
      maxLength: maxLength,
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      enabled: enabled,
      onChanged: onChange,
      // style: TextStyle(
      //   fontFamily: Fonts.montserrat,
      // ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 10),
        hintText: hints,
        hintStyle: TextStyle(color: AppColors.lightBlackColor, fontWeight: FontWeight.w300, fontSize: responsive(15, context)),
        suffixIcon: GestureDetector(
            onTap: toggleEyeIcon,
            child: Icon(
              suffixIcon,
              color: AppColors.primaryColor,
              size: responsive(22, context),
            )),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive(5, context)),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive(5, context)),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive(5, context)),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive(5, context)),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: responsive(15, context)),
    );
  }
}
