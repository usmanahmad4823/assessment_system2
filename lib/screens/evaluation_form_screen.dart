import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../model/assessment_detail_model.dart';
import '../repos/assessment_repository.dart';
import '../services/sync_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final studentsData = await _repository.getStudents();
      final detailsData = await _repository.getAssessmentDetails(widget.assessmentId);

      // Assign manual IDs (1, 2, 3...)
      for (var i = 0; i < studentsData.length; i++) {
        studentsData[i]['manual_id'] = i + 1;
        // Fallback for legacy cache having 'name' but not 'user_full_name'
        if (studentsData[i]['user_full_name'] == null) {
           studentsData[i]['user_full_name'] = studentsData[i]['name'];
        }
      }

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

  Future<void> _handleReload() async {
    setState(() => isLoading = true);
    try {
      final message = await SyncService.syncPendingEvaluations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error syncing: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
          studentId: selectedStudent['manual_id'], // Pass the manual ID as requested
          studentName: studentName,
          assessmentDetailId: detail.id,
          obtainedMarks: obtainedMarks,
          comments: teacherComment,
          evaluation: evaluation,
        );
        
        if (!synced) {
             savedLocally = true;
        }
      }
      if (mounted) {
        final msg = savedLocally 
            ? 'No internet. Saved locally.' 
            : 'Evaluation submitted successfully!';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
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
      appBar: AppBar(
        title: Text('Evaluate: ${widget.assessmentTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleReload,
          ),
        ],
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
                       DropdownSearch<dynamic>(
                        items: students,
                        itemAsString: (item) {
                          final name = item['user_full_name']?.toString() ?? item['name']?.toString() ?? 'Unknown';
                          return '${item['manual_id']} - $name';
                        },
                        selectedItem: selectedStudent,
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          menuProps: MenuProps(
                            backgroundColor: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          searchFieldProps: const TextFieldProps(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Search student',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.search, color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                            ),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            final name = item['user_full_name']?.toString() ?? item['name']?.toString() ?? 'Unknown';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text(
                                '${item['manual_id']} - $name',
                                style: TextStyle(
                                  color: isSelected ? Colors.blue : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                          scrollbarProps: const ScrollbarProps(thickness: 0),
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Student',
                            labelStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        dropdownBuilder: (context, selectedItem) {
                          if (selectedItem == null) {
                            return const Text('Select Student', style: TextStyle(color: Colors.white54));
                          }
                          final name = selectedItem['user_full_name']?.toString() ?? selectedItem['name']?.toString() ?? 'Unknown';
                          return Text(
                            '${selectedItem['manual_id']} - $name',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          );
                        },
                        onChanged: (value) => setState(() => selectedStudent = value),
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
