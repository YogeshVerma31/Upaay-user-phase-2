import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String title;
  final GestureTapCallback onPressed;
  final Color color = Colors.white;
  final double size = 16.0;

  const MyTextButton(
      {Key? key,
      required this.title,
      required this.onPressed,
      Colors? color,
      double? size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: size),
      ),
      onPressed: onPressed,
    );
  }
}
