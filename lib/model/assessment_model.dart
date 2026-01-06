class Assessment {
  final int id;
  final String assessmentTitle;

  Assessment({
    required this.id,
    required this.assessmentTitle,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] ?? 0,
      assessmentTitle: json['assessment_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_title': assessmentTitle,
    };
  }
}
