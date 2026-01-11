class AssessmentDetail {
  final int id;
  final int assessmentId;
  final String description;
  final int totalMarks;
  final String isComment;

  AssessmentDetail({
    required this.id,
    required this.assessmentId,
    required this.description,
    required this.totalMarks,
    required this.isComment,
  });

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      id: json['id'] ?? 0,
      assessmentId: json['assessment_id'] ?? 0,
      description: json['description'] ?? '',
      totalMarks: json['total_marks'] ?? 0,
      isComment: json['is_comment'] ?? 'no',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'description': description,
      'total_marks': totalMarks,
      'is_comment': isComment,
    };
  }
}

