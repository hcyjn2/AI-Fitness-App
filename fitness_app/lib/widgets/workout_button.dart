import 'package:flutter/material.dart';

class WorkoutButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onPressed;
  final double elevation;

  WorkoutButton(
      {required this.child,
      required this.color,
      this.onPressed,
      this.elevation = 10.0});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        enableFeedback: true,
        elevation: MaterialStateProperty.resolveWith((states) => elevation),
        backgroundColor: MaterialStateColor.resolveWith((states) => color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
