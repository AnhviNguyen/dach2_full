import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryYellow = Color(0xFFFDD835);
  static const Color lightYellow = Color(0xFFFBE389);
  static const Color penguinBlue = Color(0xFF5B6B8F);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}

// lib/utils/validators.dart
class Validators {
  static bool isValidLessonId(String id) {
    return id.isNotEmpty && int.tryParse(id) != null;
  }
}
