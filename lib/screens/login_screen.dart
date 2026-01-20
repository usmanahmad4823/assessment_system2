import 'dart:ui' as ui;
import 'dart:convert';
import 'package:assessment_system2/screens/assessment_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final url = Uri.parse('https://bgnu.space/api/submit_login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'login': loginController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      setState(() => isLoading = false);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        final userData = jsonResponse['data'];
        final prefs = await SharedPreferences.getInstance();
        if (userData != null) {
          final numericId = userData['id'].toString();
          await prefs.setString('user_numeric_id', numericId);
          await prefs.setInt('id', int.tryParse(numericId) ?? 0);
          await prefs.setString('full_name', userData['full_name'] ?? '');
          await prefs.setString('cellno', userData['cellno'] ?? '');
          await prefs.setString('email', userData['email'] ?? '');

          await _fetchEncryptedId(numericId);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssessmentList()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Invalid login'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _fetchEncryptedId(String numericId) async {
    try {
      final url = Uri.parse('https://bgnu.space/api/student_data?my_id=$numericId');
      final response = await http.get(url);
      final decoded = jsonDecode(response.body);
      
      if (decoded['status'] == true && decoded['data'] != null && decoded['data'].isNotEmpty) {
        final myEncryptedId = decoded['data'][0]['my_id']?.toString() ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('my_id', myEncryptedId);
      }
    } catch (e) {
      debugPrint('Error fetching encrypted ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5856D6).withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Assessment',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white38,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: loginController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Email or Phone',
                                  prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Account ID is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Password is required' : null,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : submitLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Sign In'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
