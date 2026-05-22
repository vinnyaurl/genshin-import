import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/features/shop/screens/shop_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final url = Uri.parse('http://10.0.2.2:3000/auth/login'); 
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim(), 
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          final String token = data['token']; 
          final String username = data['user']['username'];
          final String role = data['user']['role'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('username', username);
          await prefs.setString('role', role);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful!'), backgroundColor: AppColors.successGreen),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen()),
            );
          }
        } else {
          final data = jsonDecode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Login failed.'), backgroundColor: AppColors.errorRed),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot connect to server.'), backgroundColor: AppColors.errorRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.bgLightBlue, Colors.white, AppColors.bgLightPurple],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -50, right: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0xFFFDE68A), shape: BoxShape.circle))),
            Positioned(bottom: -50, left: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0xFF93C5FD), shape: BoxShape.circle))),
            Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent))),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.5)]),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Genshin Import', style: AppTheme.headerStyle.copyWith(fontSize: 32, color: AppColors.primaryAmberDark)),
                            const SizedBox(height: 12),
                            const Text('Acquire resources for your journey!', style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 40),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email Address', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(hintText: 'Enter your email'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Email cannot be empty';
                                    if (!value.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Password', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(hintText: 'Enter your password'),
                                  validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            CustomButton(text: 'Login', isLoading: _isLoading, onPressed: _handleLogin),
                            
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? ", style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 13, fontWeight: FontWeight.w500)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                  child: const Text('Register here', style: TextStyle(color: AppColors.primaryAmberDark, fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or continue with', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold))),
                                const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSocialButton(child: RichText(text: const TextSpan(style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), children: [
                                  TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))), TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))), TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))), TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))), TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))), TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
                                ]))),
                                _buildSocialButton(child: const Text('Facebook', style: TextStyle(color: Color(0xFF5856D6), fontSize: 13, fontWeight: FontWeight.bold))),
                                _buildSocialButton(child: const Text('Twitter', style: TextStyle(color: Color(0xFF1DA1F2), fontSize: 13, fontWeight: FontWeight.bold))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: child,
    );
  }
}