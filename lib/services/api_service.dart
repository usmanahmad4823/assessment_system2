import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:isolate';
import '../model/assessment_model.dart';
import '../model/assessment_detail_model.dart';
import '../model/student_model.dart';

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
        // Use Isolate.run for parsing large JSON data
        return await Isolate.run(() {
          final json = jsonDecode(response.body);
          if (json['success'] == true) {
            return (json['data'] as List)
                .map((item) => Assessment.fromJson(item))
                .toList();
          } else {
            throw Exception(json['message'] ?? 'Failed to load assessments');
          }
        });
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
        // Use Isolate.run for parsing large JSON data
        return await Isolate.run(() {
          final json = jsonDecode(response.body);
          if (json['success'] == true) {
            return (json['data'] as List)
                .map((item) => AssessmentDetail.fromJson(item))
                .toList();
          } else {
            throw Exception(json['message'] ?? 'Failed to load details');
          }
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all students
  static Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('https://bgnu.space/api/student_data'),
      );

      if (response.statusCode == 200) {
        // Use Isolate.run for parsing large JSON data
        return await Isolate.run(() {
          final decoded = jsonDecode(response.body);
          if (decoded['status'] == true) {
            return decoded['data'] as List<dynamic>;
          } else {
            throw Exception('API returned status false');
          }
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  // Submit evaluation
  static Future<bool> submitEvaluation({
    required dynamic studentId,
    required int assessmentDetailId,
    required int obtainedMarks,
    String comments = '',
    String evaluation = '',
    required String studentName,
    required String submittedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submitEvaluation.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'student_name': studentName,
          'assessment_detail_id': assessmentDetailId,
          'obtained_marks': obtainedMarks,
          'comments': comments,
          'evaluation': evaluation,
          'submitted_by': submittedBy,
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
