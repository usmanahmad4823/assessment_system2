import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/assessment_model.dart';
import '../repos/assessment_repository.dart';
import 'evaluation_form_screen.dart';
import 'profile_screen.dart';

class AssessmentList extends StatefulWidget {
  const AssessmentList({super.key});

  @override
  State<AssessmentList> createState() => _AssessmentListState();
}

class _AssessmentListState extends State<AssessmentList> {
  late Future<List<Assessment>> futureAssessments;
  final AssessmentRepository _repository = AssessmentRepository();
  String fullName = '';
  String userId = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('full_name') ?? '';
      userId = prefs.getString('user_numeric_id') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    futureAssessments = _repository.getAssessments();
  }

  void _showPasswordDialog(BuildContext context, Assessment assessment) {
    final TextEditingController passwordController = TextEditingController();
    bool isVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withOpacity(0.12), width: 0.8),
                ),
                title: const Text(
                  "Verification",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter password to access this assessment.",
                      style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: -0.1),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: passwordController,
                      obscureText: !isVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (passwordController.text == assessment.password) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EvaluationFormScreen(
                              assessmentId: assessment.id,
                              assessmentTitle: assessment.assessmentTitle,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Incorrect password"),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Verify"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Assessments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          ).then((_) => _loadUserData());
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            child: Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Available tasks to complete",
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10, letterSpacing: -0.1),
                  ),
                ),
                const SizedBox(height: 24),

                // Professional Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Search assessments...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: FutureBuilder<List<Assessment>>(
                    future: futureAssessments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.2), size: 40),
                                const SizedBox(height: 16),
                                Text(
                                  "Something went wrong",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 24),
                                TextButton(
                                  onPressed: () => setState(() {
                                    futureAssessments = _repository.getAssessments();
                                  }),
                                  child: const Text("Try Again", style: TextStyle(color: Color(0xFF007AFF))),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No assessments found", style: TextStyle(color: Colors.white24)),
                        );
                      }

                      final allAssessments = snapshot.data!;
                      final assessments = allAssessments.where((a) {
                        return a.assessmentTitle.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (assessments.isEmpty && _searchQuery.isNotEmpty) {
                        return Center(
                          child: Text(
                            "No matches for '$_searchQuery'",
                            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: assessments.length,
                        itemBuilder: (context, index) {
                          final assessment = assessments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => _showPasswordDialog(context, assessment),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF007AFF).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Icon(Icons.assignment_rounded, color: Color(0xFF007AFF), size: 20),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  assessment.assessmentTitle,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    letterSpacing: -0.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Begin evaluation",
                                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.15)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
