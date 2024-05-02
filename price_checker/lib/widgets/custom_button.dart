import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;
  final String buttonText;

  CustomButton({
    required this.color,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color,
      ),
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}
