import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Market Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1e2328)),
        scaffoldBackgroundColor: Color(0xFF1e2328),
        textTheme: Typography.whiteMountainView,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}




