import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/shop/screens/shop_screen.dart';
import '../../../features/auth/screens/login_screen.dart';
import '../../../features/auth/screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      theme: AppTheme.theme, 
      home: const LoginScreen(),
    );
  }
}
