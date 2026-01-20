import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String email = '';
  String cellNo = '';
  String userId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('full_name') ?? 'User';
      email = prefs.getString('email') ?? 'No email';
      cellNo = prefs.getString('cellno') ?? 'No phone';
      userId = prefs.getString('user_numeric_id') ?? '0';
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: 100,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          fullName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: $userId",
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Info Cards
                  _buildInfoTile(Icons.alternate_email_rounded, "Email", email),
                  const SizedBox(height: 12),
                  _buildInfoTile(Icons.phone_iphone_rounded, "Phone", cellNo),
                  
                  const SizedBox(height: 48),
                  
                  // Logout Button
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withOpacity(0.12), width: 0.8),
                        ),
                        child: TextButton(
                          onPressed: _logout,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white54, size: 20),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
