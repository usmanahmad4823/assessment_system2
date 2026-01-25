class ReceivedEvaluation {
  final String id;
  final String studentId;
  final String studentName;
  final String assessmentDetailId;
  final int obtainedMarks;
  final String comments;
  final String evaluation; // JSON string of criteria
  final String submittedBy; // Determine who evaluated (Evaluator Name/ID)
  final String createdAt;
  final String criteriaDescription;
  final int totalMarks;
  final String assessmentTitle;

  ReceivedEvaluation({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.assessmentDetailId,
    required this.obtainedMarks,
    required this.comments,
    required this.evaluation,
    required this.submittedBy,
    required this.createdAt,
    required this.criteriaDescription,
    required this.totalMarks,
    required this.assessmentTitle,
  });

  factory ReceivedEvaluation.fromJson(Map<String, dynamic> json) {
    return ReceivedEvaluation(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      studentName: json['student_name'] ?? '',
      assessmentDetailId: json['assessment_detail_id'].toString(),
      obtainedMarks: int.tryParse(json['obtained_marks']?.toString() ?? '0') ?? 0,
      comments: json['comments'] ?? '',
      evaluation: json['evaluation'] ?? '',
      submittedBy: json['submitted_by'] ?? 'Unknown',
      createdAt: json['created_at'] ?? '',
      criteriaDescription: json['criteria_description'] ?? 'Criteria',
      totalMarks: int.tryParse(json['total_marks']?.toString() ?? '0') ?? 0,
      assessmentTitle: json['assessment_title'] ?? 'Assessment',
    );
  }
}
