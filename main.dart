//-----1. Import Packages & Files-----------------------------------------
import 'package:flutter/material.dart';
import 'login.dart';

//-----2. Run App-------------------------------------------
void main() => runApp(const MyApp());

//-----3. Root Function-------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'CampusPulse';

//-----4. Root Widget---------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
