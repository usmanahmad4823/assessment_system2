class Assessment {
  final int id;
  final String assessmentTitle;
  final String password;

  Assessment({
    required this.id,
    required this.assessmentTitle,
    required this.password,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] ?? 0,
      assessmentTitle: json['assessment_title'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_title': assessmentTitle,
      'password': password,
    };
  }
}
