import 'package:flutter/material.dart';
import 'package:shopmatcher/websitePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Primary color for your app
        primaryColor: Colors.deepPurple, // Primary color for the status bar
        // accentColor: Colors.deepPurple, // Accent color for the status bar
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyWebsite(),
    );
  }
}

