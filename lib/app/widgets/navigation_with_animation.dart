import 'package:flutter/material.dart';
import 'package:get/get.dart';

void navigateWithAnimation(String route) {
  Get.defaultDialog(
    title: '',
    content: Container(
      padding: const EdgeInsets.all(20),
      child: const CircularProgressIndicator(
        color: Color(0xFF6C63FF),
      ),
    ),
    barrierDismissible: false,
    backgroundColor: Colors.transparent,
  );

  Future.delayed(const Duration(milliseconds: 1500), () {
    Get.back();
    Get.toNamed(route);
  });
} 