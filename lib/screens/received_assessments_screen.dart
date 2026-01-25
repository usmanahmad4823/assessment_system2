import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/received_evaluation_model.dart';
import '../services/api_service.dart';

class ReceivedAssessmentsScreen extends StatefulWidget {
  const ReceivedAssessmentsScreen({super.key});

  @override
  State<ReceivedAssessmentsScreen> createState() => _ReceivedAssessmentsScreenState();
}

class _ReceivedAssessmentsScreenState extends State<ReceivedAssessmentsScreen> {
  List<ReceivedEvaluation> _allEvaluations = [];
  Map<String, List<ReceivedEvaluation>> _groupedEvaluations = {};
  Map<String, List<ReceivedEvaluation>> _filteredGroupedEvaluations = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    // Assuming 'user_numeric_id' is the student ID used in the database
    _studentId = prefs.getString('user_numeric_id') ?? '';
    
    if (_studentId.isNotEmpty) {
      try {
        final evaluations = await ApiService.getReceivedEvaluations(_studentId);
        if (mounted) {
          setState(() {
            _allEvaluations = evaluations;
            _groupedEvaluations = _groupEvaluations(evaluations);
            _filteredGroupedEvaluations = _groupedEvaluations;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $e')),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<ReceivedEvaluation>> _groupEvaluations(List<ReceivedEvaluation> evaluations) {
    final Map<String, List<ReceivedEvaluation>> grouped = {};
    for (var evaluation in evaluations) {
      // Group by Assessment Title and Evaluator
      // Removed createdAt to ensure all criteria for the same assessment appear in one box
      final key = '${evaluation.assessmentTitle}||${evaluation.submittedBy}';
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
        final filtered = <String, List<ReceivedEvaluation>>{};
        _groupedEvaluations.forEach((key, evaluations) {
          if (evaluations.isNotEmpty) {
            final assessmentTitle = evaluations.first.assessmentTitle.toLowerCase();
            final evaluator = evaluations.first.submittedBy.toLowerCase();
            final searchLower = query.toLowerCase();
            if (assessmentTitle.contains(searchLower) || evaluator.contains(searchLower)) {
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
        title: const Text('Received Assessments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
            // Background Aesthetic
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34C759).withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.06),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            onChanged: _filterEvaluations,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by assessment or evaluator...',
                              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.5), size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              isDense: true,
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
                              strokeWidth: 2,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 60,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No Received Assessments' : 'No Results Found',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student ID: $_studentId',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Evaluations submitted for you will appear here'
                : 'Try a different search term',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedEvaluationCard(List<ReceivedEvaluation> evaluations) {
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
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Title and Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                              firstEval.assessmentTitle,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.titleLarge?.color,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                             Text(
                              'Evaluated by: ${firstEval.submittedBy}',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                           ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$totalObtained / $totalMax',
                          style: const TextStyle(
                            color: Color(0xFF34C759),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),

                  // Individual Criteria
                  ...evaluations.map((evaluation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.02)
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    evaluation.criteriaDescription,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (evaluation.totalMarks > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${evaluation.obtainedMarks}/${evaluation.totalMarks}',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (evaluation.comments.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                evaluation.comments,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
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
                        size: 11,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(firstEval.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
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
