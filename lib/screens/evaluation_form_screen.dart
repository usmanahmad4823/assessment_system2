import 'package:flutter/material.dart';
import '../model/assessment_detail_model.dart';
import '../services/api_service.dart';

class EvaluationFormScreen extends StatefulWidget {
  final int assessmentId;
  final String assessmentTitle;

  const EvaluationFormScreen({
    Key? key,
    required this.assessmentId,
    required this.assessmentTitle,
  }) : super(key: key);

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  List<AssessmentDetail> details = [];
  List<Student> students = [];
  Student? selectedStudent;
  final Map<int, TextEditingController> marksControllers = {};
  final Map<int, TextEditingController> commentControllers = {};
  
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load both students and assessment details
      final studentsData = await ApiService.getStudents();
      final detailsData = await ApiService.getAssessmentDetails(widget.assessmentId);

      setState(() {
        students = studentsData;
        details = detailsData;
        
        // Initialize controllers
        for (var detail in details) {
          marksControllers[detail.id] = TextEditingController();
          commentControllers[detail.id] = TextEditingController();
        }
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load data: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var c in marksControllers.values) {
      c.dispose();
    }
    for (var c in commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (selectedStudent == null) {
      setState(() => errorMessage = 'Please select a student');
      return;
    }
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    try {
      for (var detail in details) {
        final teacherComment = commentControllers[detail.id]?.text ?? '';
        final isCommentOnly = detail.isComment.toLowerCase() == 'yes';
        
        // Critical: Set marks to 0 if teacher's comment is "yes" (case-insensitive)
        int obtainedMarks;
        if (teacherComment.trim().toLowerCase() == 'yes') {
          obtainedMarks = 0;
        } else if (isCommentOnly) {
           obtainedMarks = 0;
        } else {
           obtainedMarks = int.tryParse(marksControllers[detail.id]?.text ?? '') ?? 0;
        }

        final evaluation = detail.description;
        
        await ApiService.submitEvaluation(
          studentId: selectedStudent!.id,
          assessmentDetailId: detail.id,
          obtainedMarks: obtainedMarks,
          comments: teacherComment,
          evaluation: evaluation,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluation submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => errorMessage = 'Submission failed: $e');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluate: ${widget.assessmentTitle}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : details.isEmpty
              ? const Center(child: Text('No details found for this assessment'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Student>(
                        value: selectedStudent,
                        dropdownColor: Colors.grey[900],
                        items: students
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('${s.rollno} - ${s.name}', style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (s) => setState(() => selectedStudent = s),
                        decoration: const InputDecoration(
                          labelText: 'Select Student (Roll No)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...details.map((detail) {
                        final isCommentOnly = detail.isComment.toLowerCase() == 'yes';
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail.description, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                if (!isCommentOnly)
                                  TextFormField(
                                    controller: marksControllers[detail.id],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Marks (out of ${detail.totalMarks})',
                                    ),
                                  ),
                                if (isCommentOnly)
                                  TextFormField(
                                    controller: commentControllers[detail.id],
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Comment',
                                      hintText: 'Enter "yes" to set marks to 0',
                                      hintStyle: TextStyle(color: Colors.white24),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
