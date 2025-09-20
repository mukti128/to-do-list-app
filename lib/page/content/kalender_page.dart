import 'package:flutter/material.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Kalender"),
      ),
    );
  }
}