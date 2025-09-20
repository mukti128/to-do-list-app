import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:to_do_list/page/register_page.dart';
import 'package:to_do_list/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: appColorScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: appColorScheme.primary,
          foregroundColor: appColorScheme.onPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColorScheme.secondary,
            foregroundColor: appColorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const RegisterPage(),
    );
  }
}
