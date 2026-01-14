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

          // Fetch and store the encrypted my_id just like the dashboard screen
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Colors.white70,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: const Color(0xFF1E1E1E).withOpacity(0.9), // Slightly different from background
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: loginController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Email or Phone',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter email or phone' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter password' : null,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: isLoading ? null : submitLogin,
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('LOGIN'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
