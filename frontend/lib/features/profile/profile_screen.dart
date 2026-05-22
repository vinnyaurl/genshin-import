import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 1; 

  bool _isLoading = true;
  String _token = '';
  String _username = 'Loading...';
  int _balance = 0;
  String _authProvider = 'Manual'; 
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final role = prefs.getString('role') ?? 'user';

    if (token.isEmpty) {
      _forceLogout();
      return;
    }

    setState(() {
      _token = token;
      _isAdmin = role == 'admin';
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/auth/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _username = data['username'] ?? 'Unknown';
            _balance = data['balance'] ?? 0;
            _authProvider = data['auth_provider'] ?? 'Manual'; 
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load profile data.'), backgroundColor: AppColors.errorRed),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error.'), backgroundColor: AppColors.errorRed),
        );
        setState(() => _isLoading = false);
      }
    }
  }


  String _formatCurrency(int value) {
    String str = value.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) result = ',' + result;
    }
    return result;
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, 
      );
    }
  }

  void _forceLogout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        isAdmin: _isAdmin,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); 
          }
        },
      ),
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
            
            SafeArea(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmberDark))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Profile',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 32,
                            color: AppColors.primaryAmberDark,
                          ),
                        ),
                        const SizedBox(height: 32),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.5)]),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 5)],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAmberLight.withValues(alpha: 0.2), 
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primaryAmberDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Text(
                                    _username,
                                    style: AppTheme.headerStyle.copyWith(
                                      fontSize: 24,
                                      color: AppColors.primaryAmberDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.monetization_on, color: AppColors.primaryAmberLight, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatCurrency(_balance),
                                        style: const TextStyle(
                                          color: AppColors.primaryAmberLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SECURITY & SESSION',
                                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Auth Provider:', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(color: AppColors.primaryAmberLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                              child: Text(
                                                _authProvider[0].toUpperCase() + _authProvider.substring(1),
                                                style: const TextStyle(color: AppColors.primaryAmberDark, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        const Text('Bearer Token:', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white),
                                          ),
                                          child: Text(
                                            _token,
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Courier'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis, 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleLogout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000), 
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}