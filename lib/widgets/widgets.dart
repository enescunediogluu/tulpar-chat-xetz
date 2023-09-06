import 'package:flutter/material.dart';

final textInputDecoration = InputDecoration(
  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
  errorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 2),
    borderRadius: BorderRadius.circular(10),
  ),
  enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(35)),
  focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(35)),
);

void nextScreen(context, page) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 19),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
