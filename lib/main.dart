import 'package:flutter/material.dart';
import 'navigator.dart';

void main() {
  runApp(const Page());
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainNavigator(usuario: []),
      debugShowCheckedModeBanner: false,
    );
  }
}