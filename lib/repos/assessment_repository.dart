import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../model/assessment_model.dart';
import '../model/assessment_detail_model.dart';
import '../model/student_model.dart';

class AssessmentRepository {
  
  // Check connectivity helper
  Future<bool> get isOnline async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet;
  }

  // Get Assessments
  Future<List<Assessment>> getAssessments() async {
    if (await isOnline) {
      try {
        final assessments = await ApiService.getAssessments();
        // Cache data
        await StorageService.saveAssessments(assessments.map((e) => e.toJson()).toList());
        return assessments;
      } catch (e) {
        // If API fails, try local
        return _getLocalAssessments();
      }
    } else {
      return _getLocalAssessments();
    }
  }

  List<Assessment> _getLocalAssessments() {
    final data = StorageService.getAssessments();
    return data.map((e) => Assessment.fromJson(e)).toList();
  }

  // Get Students
  Future<List<dynamic>> getStudents() async {
    try {
      final students = await ApiService.getStudents();
      await StorageService.saveStudents(students);
      return students;
    } catch (e) {
      return _getLocalStudents();
    }
  }

  List<dynamic> _getLocalStudents() {
    return StorageService.getStudents();
  }

  // Get Assessment Details
  Future<List<AssessmentDetail>> getAssessmentDetails(int assessmentId) async {
    if (await isOnline) {
      try {
        final details = await ApiService.getAssessmentDetails(assessmentId);
        await StorageService.saveAssessmentDetails(assessmentId, details.map((e) => e.toJson()).toList());
        return details;
      } catch (e) {
        return _getLocalAssessmentDetails(assessmentId);
      }
    } else {
      return _getLocalAssessmentDetails(assessmentId);
    }
  }

  List<AssessmentDetail> _getLocalAssessmentDetails(int assessmentId) {
    final data = StorageService.getAssessmentDetails(assessmentId);
    return data.map((e) => AssessmentDetail.fromJson(e)).toList();
  }

  // Submit Evaluation
  // Returns true if synced online, false if saved locally
  Future<bool> submitEvaluation({
    required dynamic studentId,
    required int assessmentDetailId,
    required int obtainedMarks,
    String comments = '',
    String evaluation = '',
    required String studentName,
  }) async {
    final payload = {
      'student_id': studentId,
      'student_name': studentName,
      'assessment_detail_id': assessmentDetailId,
      'obtained_marks': obtainedMarks,
      'comments': comments,
      'evaluation': evaluation,
    };

    if (await isOnline) {
      try {
        await ApiService.submitEvaluation(
          studentId: studentId,
          studentName: studentName,
          assessmentDetailId: assessmentDetailId,
          obtainedMarks: obtainedMarks,
          comments: comments,
          evaluation: evaluation,
        );
        return true; 
      } catch (e) {
        // If API fails, save to queue
        await StorageService.addToQueue(payload);
        return false;
      }
    } else {
      await StorageService.addToQueue(payload);
      return false;
    }
  }
}
