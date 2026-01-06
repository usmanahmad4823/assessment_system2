import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/assessment_model.dart';
import '../model/assessment_detail_model.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'https://devntec.com/assessmentsystem2';

  // Get all assessments
  static Future<List<Assessment>> getAssessments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessmentList.php?action=get_all'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          List<Assessment> assessments = (json['data'] as List)
              .map((item) => Assessment.fromJson(item))
              .toList();
          return assessments;
        } else {
          throw Exception(json['message'] ?? 'Failed to load assessments');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get assessment details by assessment ID
  static Future<List<AssessmentDetail>> getAssessmentDetails(int assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessmentList.php?action=get_details&id=$assessmentId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          List<AssessmentDetail> details = (json['data'] as List)
              .map((item) => AssessmentDetail.fromJson(item))
              .toList();
          return details;
        } else {
          throw Exception(json['message'] ?? 'Failed to load details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all students
  static Future<List<Student>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getStudents.php'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          List<Student> students = (json['data'] as List)
              .map((item) => Student.fromJson(item))
              .toList();
          return students;
        } else {
          throw Exception(json['message'] ?? 'Failed to load students');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Submit evaluation
  static Future<bool> submitEvaluation({
    required int studentId,
    required int assessmentDetailId,
    required int obtainedMarks,
    String comments = '',
    String evaluation = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submitEvaluation.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'assessment_detail_id': assessmentDetailId,
          'obtained_marks': obtainedMarks,
          'comments': comments,
          'evaluation': evaluation,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
