import 'package:flutter/material.dart';

import '../constants/colorconstants.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      // autofocus: true,
      maxLines: 1,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(232, 232, 232, 0.5),
        hintText: hintText,
        hintStyle: const TextStyle(color: strikethroughColor),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
                color: strikethroughColor, width: 1, style: BorderStyle.solid)),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
                color: strikethroughColor, width: 1, style: BorderStyle.solid)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        isDense: true, // Added this
      ),
      style: const TextStyle(fontSize: 12),
      textInputAction: TextInputAction.search,
    );
  }
}
