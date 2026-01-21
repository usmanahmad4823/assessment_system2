import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:isolate';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../model/assessment_model.dart';
import '../model/assessment_detail_model.dart';
import '../model/student_model.dart';
import '../model/submitted_evaluation_model.dart';

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
    final localData = await _getLocalAssessments();
    
    // If we have local data, return it immediately and update in background
    if (localData.isNotEmpty) {
      _fetchAndCacheAssessments(); // Background fetch
      return localData;
    }

    // If no local data, wait for network
    if (await isOnline) {
      return await _fetchAndCacheAssessments();
    }
    
    return [];
  }

  Future<List<Assessment>> _fetchAndCacheAssessments() async {
    try {
      final assessments = await ApiService.getAssessments();
      final jsonList = await Isolate.run(() => assessments.map((e) => e.toJson()).toList());
      await StorageService.saveAssessments(jsonList);
      return assessments;
    } catch (e) {
      return [];
    }
  }

  Future<List<Assessment>> _getLocalAssessments() async {
    final data = StorageService.getAssessments();
    if (data.isEmpty) return [];
    // Use isolate for mapping large lists
    return await Isolate.run(() => data.map((e) => Assessment.fromJson(e)).toList());
  }

  // Get Students
  Future<List<dynamic>> getStudents() async {
    final localStudents = _getLocalStudents();
    
    if (localStudents.isNotEmpty) {
      _fetchAndCacheStudents(); // Background fetch
      return localStudents;
    }

    if (await isOnline) {
      return await _fetchAndCacheStudents();
    }

    return [];
  }

  Future<List<dynamic>> _fetchAndCacheStudents() async {
    try {
      final students = await ApiService.getStudents();
      await StorageService.saveStudents(students);
      return students;
    } catch (e) {
      return [];
    }
  }

  List<dynamic> _getLocalStudents() {
    return StorageService.getStudents();
  }

  // Get Assessment Details
  Future<List<AssessmentDetail>> getAssessmentDetails(int assessmentId) async {
    final localDetails = await _getLocalAssessmentDetails(assessmentId);

    if (localDetails.isNotEmpty) {
      _fetchAndCacheAssessmentDetails(assessmentId); // Background fetch
      return localDetails;
    }

    if (await isOnline) {
      return await _fetchAndCacheAssessmentDetails(assessmentId);
    }

    return [];
  }

  Future<List<AssessmentDetail>> _fetchAndCacheAssessmentDetails(int assessmentId) async {
    try {
      final details = await ApiService.getAssessmentDetails(assessmentId);
      final jsonList = await Isolate.run(() => details.map((e) => e.toJson()).toList());
      await StorageService.saveAssessmentDetails(assessmentId, jsonList);
      return details;
    } catch (e) {
      return [];
    }
  }

  Future<List<AssessmentDetail>> _getLocalAssessmentDetails(int assessmentId) async {
    final data = StorageService.getAssessmentDetails(assessmentId);
    if (data.isEmpty) return [];
    // Use isolate for mapping large lists
    return await Isolate.run(() => data.map((e) => AssessmentDetail.fromJson(e)).toList());
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
    required String submittedBy,
  }) async {
    final payload = {
      'student_id': studentId,
      'student_name': studentName,
      'assessment_detail_id': assessmentDetailId,
      'obtained_marks': obtainedMarks,
      'comments': comments,
      'evaluation': evaluation,
      'submitted_by': submittedBy,
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
          submittedBy: submittedBy,
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

  // Get Submitted Evaluations
  Future<List<SubmittedEvaluation>> getSubmittedEvaluations(String submittedBy) async {
    final localData = await _getLocalSubmittedEvaluations(submittedBy);
    
    // If we have local data, return it immediately and update in background
    if (localData.isNotEmpty) {
      _fetchAndCacheSubmittedEvaluations(submittedBy); // Background fetch
      return localData;
    }

    // If no local data, wait for network
    if (await isOnline) {
      return await _fetchAndCacheSubmittedEvaluations(submittedBy);
    }
    
    return [];
  }

  Future<List<SubmittedEvaluation>> _fetchAndCacheSubmittedEvaluations(String submittedBy) async {
    try {
      final evaluations = await ApiService.getSubmittedEvaluations(submittedBy);
      await StorageService.saveSubmittedEvaluations(submittedBy, evaluations);
      // Use isolate for mapping large lists
      return await Isolate.run(() => evaluations.map((e) => SubmittedEvaluation.fromJson(e)).toList());
    } catch (e) {
      return [];
    }
  }

  Future<List<SubmittedEvaluation>> _getLocalSubmittedEvaluations(String submittedBy) async {
    final data = StorageService.getSubmittedEvaluations(submittedBy);
    if (data.isEmpty) return [];
    // Use isolate for mapping large lists
    return await Isolate.run(() => data.map((e) => SubmittedEvaluation.fromJson(e)).toList());
  }
}
