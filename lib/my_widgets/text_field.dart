// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_app_one/utils/app_colors.dart';

class MyTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final myController;
  final type;
  final length;
  final active;
  final icon;
  final text;
  final label;
  final alignment;
  final prefix;

  const MyTextField(
      {Key? key,
      this.active = true,
      this.text = '',
      this.type,
      this.label = '',
      // ignore: avoid_init_to_null
      this.icon = null,
      this.length,
      this.hint = '',
      this.isPassword = false,
      this.myController,
      this.alignment = TextAlign.start,
      this.prefix = '   '})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.backgroundcolor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(width: 1, color: AppColors.appGreen)),
      child: TextField(
        enabled: active,
        keyboardType: type,
        maxLength: length,
        controller: myController,
        obscureText: isPassword,
        textAlign: alignment,
        style: const TextStyle(color: AppColors.lightTextColor),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.lightTextColor),
            border: InputBorder.none,
            isDense: true,
            prefixIcon: Text(
              prefix,
              style: const TextStyle(color: AppColors.lightTextColor),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            counterText: '',
            /* label: Text(
              label,
              style: const TextStyle(color: Colors.black),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            floatingLabelStyle: const TextStyle(color: Colors.black), */
            contentPadding: const EdgeInsets.all(20)),
      ),
    );
  }
}
