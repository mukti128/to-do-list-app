import 'package:flutter/material.dart';

const ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF42A5F5), // ocean blue
  onPrimary: Colors.white,
  secondary: Color(0xFF1E88E5), // royal blue
  onSecondary: Colors.white,
  tertiary: Color(0xFF90CAF9), // soft blue
  onTertiary: Colors.black,
  error: Color(0xFFD32F2F),
  onError: Colors.white,
  surface: Color(0xFFE3F2FD), // sky blue (cerah & soft)
  onSurface: Colors.black,
);

const ColorScheme appColorSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF1565C0), // deep blue
  onPrimary: Colors.white,
  secondary: Color(0xFF1E88E5), // royal blue terang
  onSecondary: Colors.white,
  tertiary: Color(0xFF90CAF9), // soft blue untuk highlight
  onTertiary: Colors.black,
  error: Color(0xFFCF6679),
  onError: Colors.black,
  surface: Color(0xFF0D1B2A), // dark navy elegan
  onSurface: Colors.white,
);
