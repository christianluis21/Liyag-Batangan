import 'package:flutter/material.dart';
import 'loading_screen.dart'; // Ensure this file exists in `lib/`
  // Also make sure this exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liyag Batangan',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        useMaterial3: true,
      ),
      home: const LoadingScreen(), // Start with the loading screen
    );
  }
}
