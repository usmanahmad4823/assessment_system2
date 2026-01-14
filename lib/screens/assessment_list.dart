import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/assessment_model.dart';
import '../repos/assessment_repository.dart';
import 'evaluation_form_screen.dart';
import 'login_screen.dart';
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
  String email = '';
  String cellNo = '';
  String userId = '';
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('full_name') ?? '';
      email = prefs.getString('email') ?? '';
      cellNo = prefs.getString('cellno') ?? '';
      userId = prefs.getString('user_numeric_id') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    futureAssessments = _repository.getAssessments();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Assessments", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Assessment", 
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        ).then((_) => _loadUserData()); // Refresh names if changed
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 32),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Assessment>>(
              future: futureAssessments,
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No assessments found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final assessments = snapshot.data!;

          // Success UI
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Assessment title
                    Expanded(
                      child: Text(
                        assessment.assessmentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EvaluationFormScreen(
                              assessmentId: assessment.id,
                              assessmentTitle: assessment.assessmentTitle,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Start"),
                    ),
                  ],
                ),
              );
            },
          );
                },
              ),
            ),
          ],
        ),
      );
    }
}
