import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../model/assessment_detail_model.dart';
import '../repos/assessment_repository.dart';
import 'package:assessment_system2/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<dynamic> students = [];
  dynamic selectedStudent;
  final Map<int, TextEditingController> marksControllers = {};
  final Map<int, TextEditingController> commentControllers = {};
  
  final AssessmentRepository _repository = AssessmentRepository();
  
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  String myId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      myId = prefs.getString('user_numeric_id') ?? 'unknown';

      final studentsData = await _repository.getStudents();
      final detailsData = await _repository.getAssessmentDetails(widget.assessmentId);

      for (var i = 0; i < studentsData.length; i++) {
        studentsData[i]['manual_id'] = i + 8;
        if (studentsData[i]['user_full_name'] == null) {
           studentsData[i]['user_full_name'] = studentsData[i]['name'];
        }
      }

      setState(() {
        students = studentsData;
        details = detailsData;
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

  Future<void> _handleReload() async {
    setState(() => isLoading = true);
    try {
      final message = await SyncService.syncPendingEvaluations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (selectedStudent == null) {
      setState(() => errorMessage = 'Please select a student');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    try {
      bool savedLocally = false;
      for (var detail in details) {
        final teacherComment = commentControllers[detail.id]?.text ?? '';
        final isCommentOnly = detail.isComment.toLowerCase() == 'yes';
        
        int obtainedMarks;
        if (teacherComment.trim().toLowerCase() == 'yes') {
          obtainedMarks = 0;
        } else if (isCommentOnly) {
           obtainedMarks = 0;
        } else {
           obtainedMarks = int.tryParse(marksControllers[detail.id]?.text ?? '') ?? 0;
        }

        final evaluation = detail.description;
        final studentName = selectedStudent['user_full_name']?.toString() ?? selectedStudent['name']?.toString() ?? 'Unknown';
        
        final synced = await _repository.submitEvaluation(
          studentId: selectedStudent['manual_id'],
          studentName: studentName,
          assessmentDetailId: detail.id,
          obtainedMarks: obtainedMarks,
          comments: teacherComment,
          evaluation: evaluation,
          submittedBy: myId,
        );
        
        if (!synced) {
             savedLocally = true;
        }
      }
      if (mounted) {
        final msg = savedLocally 
            ? 'Access saved locally (offline)' 
            : 'Evaluation successful';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: savedLocally ? Colors.orangeAccent.withOpacity(0.9) : const Color(0xFF34C759),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.assessmentTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.sync_rounded, size: 20, color: Theme.of(context).iconTheme.color),
            onPressed: _handleReload,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withOpacity(0.06),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : details.isEmpty
              ? Center(child: Text('No evaluation items found', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Student Selection',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            letterSpacing: 0.5,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: DropdownSearch<dynamic>(
                              items: students,
                              itemAsString: (item) {
                                final name = item['user_full_name']?.toString() ?? item['name']?.toString() ?? 'Unknown';
                                return '${item['manual_id']} - $name';
                              },
                              selectedItem: selectedStudent,
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                menuProps: MenuProps(
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1C1C1E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  elevation: 8,
                                ),
                                searchFieldProps: TextFieldProps(
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search student...',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.03)
                                      : Colors.black.withOpacity(0.03),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                  ),
                                ),
                                itemBuilder: (context, item, isSelected) {
                                  final name = item['user_full_name']?.toString() ?? item['name']?.toString() ?? 'Unknown';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Text(
                                      '${item['manual_id']} - $name',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF007AFF)
                                            : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  hintText: 'Select Student',
                                  filled: false,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                              ),
                              onChanged: (value) => setState(() => selectedStudent = value),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Evaluation Items',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...details.map((detail) {
                        final isCommentOnly = detail.isComment.toLowerCase() == 'yes';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.04)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.15)
                                        : Colors.black.withOpacity(0.12),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            detail.description,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).textTheme.titleMedium?.color,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        if (!isCommentOnly)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF007AFF).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Max Marks: ${detail.totalMarks}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF007AFF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    if (!isCommentOnly)
                                      TextFormField(
                                        controller: marksControllers[detail.id],
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: 'Marks',
                                          hintText: '0 - ${detail.totalMarks}',
                                          prefixIcon: const Icon(Icons.stars_rounded, size: 20),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          final marks = int.tryParse(value);
                                          if (marks == null) return 'Invalid';
                                          if (marks < 0 || marks > detail.totalMarks) return '0 to ${detail.totalMarks}';
                                          return null;
                                        },
                                      ),
                                    if (isCommentOnly)
                                      TextFormField(
                                        controller: commentControllers[detail.id],
                                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
                                        decoration: const InputDecoration(
                                          labelText: 'Feedback',
                                          hintText: 'Enter comment...',
                                          prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      if (errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('SUBMIT'),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
