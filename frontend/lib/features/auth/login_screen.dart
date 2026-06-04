import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import '../shop/shop_screen.dart';

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

  // ✅ Flag untuk tahu apakah Google Sign In sudah siap
  bool _isGoogleReady = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      // ✅ Pakai clientId, bukan serverClientId
      await GoogleSignIn.instance.initialize(
        clientId: '619276703872-0crc68dnh5p67q42bnul8it4rf8jtche.apps.googleusercontent.com',
      );
      if (mounted) setState(() => _isGoogleReady = true);
      debugPrint("✅ Google Sign In ready");
    } catch (e) {
      debugPrint("❌ Error initializing Google Sign In: $e");
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('username', data['user']['username']);
          await prefs.setString('role', data['user']['role']);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successful!'),
                backgroundColor: AppColors.successGreen,
              ),
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
              SnackBar(
                content: Text(data['message'] ?? 'Login failed.'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Login Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot connect to server.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLoginNative() async {
    // ✅ Kalau belum siap, tampilkan pesan dan jangan lanjut
    if (!_isGoogleReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign In sedang disiapkan, coba lagi...')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ Pakai GoogleSignIn.instance langsung, bukan _googleSignIn
      final GoogleSignInAccount? acc = await GoogleSignIn.instance.authenticate();
      if (acc == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication userAuth = await acc.authentication;
      final String? idToken = userAuth.idToken;

      // ✅ Cek idToken tidak null sebelum dikirim
      if (idToken == null) {
        throw Exception('idToken is null — pastikan clientId benar dan SHA-1 sudah didaftarkan');
      }

      debugPrint("✅ idToken diperoleh, mengirim ke backend...");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/google/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        // ✅ Ambil dari response backend, bukan dari acc.displayName
        await prefs.setString('username', result['user']['username']);
        await prefs.setString('role', result['user']['role']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Login Successful!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShopScreen()),
          );
        }
      } else {
        final result = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Google login failed.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // ✅ Tampilkan error spesifik di snackbar dan console
      debugPrint("❌ Google Login Error: $e");
      debugPrint("Stack: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgLightBlue, Colors.white, AppColors.bgLightPurple],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text('Genshin Import', style: AppTheme.headerStyle),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email cannot be empty';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Login',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 20),
                    // ✅ Tombol Google dengan indikator loading saat belum siap
                    GestureDetector(
                      onTap: _isLoading ? null : _handleGoogleLoginNative,
                      child: _buildSocialButton(
                        child: _isGoogleReady
                            ? const Text(
                                'Sign in with Google',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }
}