import 'package:flutter/material.dart';

import '../utils/styles.dart';

class CustomCheckBoxButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  CustomCheckBoxButton({
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomCheckBoxButtonState createState() => _CustomCheckBoxButtonState();
}

class _CustomCheckBoxButtonState extends State<CustomCheckBoxButton> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.value,
      onChanged: widget.onChanged,
      activeColor: AppColors.primaryColor,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }
}
