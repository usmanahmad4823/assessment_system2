import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/submitted_evaluation_model.dart';
import '../repos/assessment_repository.dart';

class SubmittedAssessmentsScreen extends StatefulWidget {
  const SubmittedAssessmentsScreen({super.key});

  @override
  State<SubmittedAssessmentsScreen> createState() => _SubmittedAssessmentsScreenState();
}

class _SubmittedAssessmentsScreenState extends State<SubmittedAssessmentsScreen> {
  final AssessmentRepository _repository = AssessmentRepository();
  List<SubmittedEvaluation> _allEvaluations = [];
  Map<String, List<SubmittedEvaluation>> _groupedEvaluations = {};
  Map<String, List<SubmittedEvaluation>> _filteredGroupedEvaluations = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('user_numeric_id') ?? '';
    
    if (_username.isNotEmpty) {
      final evaluations = await _repository.getSubmittedEvaluations(_username);
      setState(() {
        _allEvaluations = evaluations;
        _groupedEvaluations = _groupEvaluations(evaluations);
        _filteredGroupedEvaluations = _groupedEvaluations;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<SubmittedEvaluation>> _groupEvaluations(List<SubmittedEvaluation> evaluations) {
    final Map<String, List<SubmittedEvaluation>> grouped = {};
    for (var evaluation in evaluations) {
      final key = '${evaluation.assessmentTitle}_${evaluation.studentId}_${evaluation.studentName}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(evaluation);
    }
    return grouped;
  }

  void _filterEvaluations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredGroupedEvaluations = _groupedEvaluations;
      } else {
        final filtered = <String, List<SubmittedEvaluation>>{};
        _groupedEvaluations.forEach((key, evaluations) {
          if (evaluations.isNotEmpty) {
            final studentName = evaluations.first.studentName.toLowerCase();
            final assessmentTitle = evaluations.first.assessmentTitle.toLowerCase();
            final searchLower = query.toLowerCase();
            if (studentName.contains(searchLower) || assessmentTitle.contains(searchLower)) {
              filtered[key] = evaluations;
            }
          }
        });
        _filteredGroupedEvaluations = filtered;
      }
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Submitted Assessments'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF000000),
              const Color(0xFF0A0A0A),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        onChanged: _filterEvaluations,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by student or assessment...',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search, color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF007AFF),
                        ),
                      )
                    : _filteredGroupedEvaluations.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: const Color(0xFF007AFF),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredGroupedEvaluations.length,
                              itemBuilder: (context, index) {
                                final key = _filteredGroupedEvaluations.keys.elementAt(index);
                                final evaluations = _filteredGroupedEvaluations[key]!;
                                return _buildGroupedEvaluationCard(evaluations);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No Submissions Yet' : 'No Results Found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Your submitted evaluations will appear here'
                : 'Try a different search term',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedEvaluationCard(List<SubmittedEvaluation> evaluations) {
    if (evaluations.isEmpty) return const SizedBox.shrink();
    
    final firstEval = evaluations.first;
    int totalObtained = 0;
    int totalMax = 0;
    
    for (var eval in evaluations) {
      totalObtained += eval.obtainedMarks;
      totalMax += eval.totalMarks;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assessment Title
                  Text(
                    firstEval.assessmentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Student Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Color(0xFF007AFF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              firstEval.studentName,
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${firstEval.studentId}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total Marks Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF007AFF).withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.grade_outlined,
                              size: 18,
                              color: Color(0xFF007AFF),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Total Marks:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$totalObtained / $totalMax',
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 0.5,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),

                  // Individual Criteria
                  ...evaluations.map((evaluation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Criteria Description
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    evaluation.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Marks for this criterion (only show if not comment-only)
                                if (evaluation.comments.isEmpty || evaluation.obtainedMarks > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${evaluation.obtainedMarks}/${evaluation.totalMarks}',
                                      style: const TextStyle(
                                        color: Color(0xFF007AFF),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            // Comments (if any)
                            if (evaluation.comments.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 12,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      evaluation.comments,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 10,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Timestamp
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(firstEval.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
