class SubmittedEvaluation {
  final int id;
  final int studentId;
  final String studentName;
  final int assessmentDetailId;
  final String assessmentTitle;
  final String description;
  final int totalMarks;
  final int obtainedMarks;
  final String comments;
  final String evaluation;
  final String submittedBy;
  final String createdAt;

  SubmittedEvaluation({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.assessmentDetailId,
    required this.assessmentTitle,
    required this.description,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.comments,
    required this.evaluation,
    required this.submittedBy,
    required this.createdAt,
  });

  factory SubmittedEvaluation.fromJson(Map<String, dynamic> json) {
    return SubmittedEvaluation(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      assessmentDetailId: json['assessment_detail_id'] ?? 0,
      assessmentTitle: json['assessment_title'] ?? '',
      description: json['description'] ?? '',
      totalMarks: json['total_marks'] ?? 0,
      obtainedMarks: json['obtained_marks'] ?? 0,
      comments: json['comments'] ?? '',
      evaluation: json['evaluation'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'assessment_detail_id': assessmentDetailId,
      'assessment_title': assessmentTitle,
      'description': description,
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'comments': comments,
      'evaluation': evaluation,
      'submitted_by': submittedBy,
      'created_at': createdAt,
    };
  }
}
