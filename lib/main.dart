import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FruitApp());
}

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
