import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class StorageService {
  static const String assessmentsBoxName = 'assessments';
  static const String studentsBoxName = 'students';
  static const String detailsBoxName = 'details';
  static const String evaluationQueueBoxName = 'evaluation_queue';
  static const String submittedEvaluationsBoxName = 'submitted_evaluations';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(assessmentsBoxName);
    await Hive.openBox(studentsBoxName);
    await Hive.openBox(detailsBoxName);
    await Hive.openBox(evaluationQueueBoxName);
    await Hive.openBox(submittedEvaluationsBoxName);
  }

  // Generic Get/Set helpers
  static Box get _assessmentsBox => Hive.box(assessmentsBoxName);
  static Box get _studentsBox => Hive.box(studentsBoxName);
  static Box get _detailsBox => Hive.box(detailsBoxName);
  static Box get _queueBox => Hive.box(evaluationQueueBoxName);
  static Box get _submittedEvaluationsBox => Hive.box(submittedEvaluationsBoxName);

  // Save Assessments
  static Future<void> saveAssessments(List<dynamic> jsonList) async {
    await _assessmentsBox.put('all', jsonEncode(jsonList));
  }

  static List<dynamic> getAssessments() {
    final String? data = _assessmentsBox.get('all');
    if (data == null) return [];
    return jsonDecode(data);
  }

  // Save Students
  static Future<void> saveStudents(List<dynamic> jsonList) async {
    await _studentsBox.put('all', jsonEncode(jsonList));
  }

  static List<dynamic> getStudents() {
    final String? data = _studentsBox.get('all');
    if (data == null) return [];
    return jsonDecode(data);
  }

  // Save Assessment Details
  static Future<void> saveAssessmentDetails(int assessmentId, List<dynamic> jsonList) async {
    await _detailsBox.put(assessmentId, jsonEncode(jsonList));
  }

  static List<dynamic> getAssessmentDetails(int assessmentId) {
    final String? data = _detailsBox.get(assessmentId);
    if (data == null) return [];
    return jsonDecode(data);
  }

  // Evaluation Queue
  static Future<void> addToQueue(Map<String, dynamic> evaluationData) async {
    await _queueBox.add(jsonEncode(evaluationData));
  }

  // Returns a map of key -> evaluationData
  static Map<dynamic, Map<String, dynamic>> getQueueWithKeys() {
    final Map<dynamic, Map<String, dynamic>> queue = {};
    for (var key in _queueBox.keys) {
      final value = _queueBox.get(key);
      if (value != null) {
        queue[key] = jsonDecode(value) as Map<String, dynamic>;
      }
    }
    return queue;
  }

  static Future<void> deleteFromQueue(dynamic key) async {
    await _queueBox.delete(key);
  }

  static Future<void> clearQueue() async {
    await _queueBox.clear();
  }

  // Save Submitted Evaluations
  static Future<void> saveSubmittedEvaluations(String submittedBy, List<dynamic> jsonList) async {
    await _submittedEvaluationsBox.put(submittedBy, jsonEncode(jsonList));
  }

  static List<dynamic> getSubmittedEvaluations(String submittedBy) {
    final String? data = _submittedEvaluationsBox.get(submittedBy);
    if (data == null) return [];
    return jsonDecode(data);
  }
}
