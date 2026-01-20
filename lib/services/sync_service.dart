import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:isolate';
import 'api_service.dart';
import 'storage_service.dart';

class SyncService {
  
  static Future<bool> isOnline() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet;
  }

  /// Tries to sync all pending evaluations.
  /// Returns a message describing the result.
  static Future<String> syncPendingEvaluations() async {
    if (!await isOnline()) {
      return "No internet connection. Data remains saved locally.";
    }

    final queue = StorageService.getQueueWithKeys();
    if (queue.isEmpty) {
      return "No pending evaluations to sync.";
    }

    // Convert keys to list for processing
    final entries = queue.entries.toList();
    
    // Use Isolate.run to handle the sync loop in background
    // Note: We only pass the data to the isolate.
    // The isolate will return a list of keys that were successfully synced.
    final List<dynamic> successKeys = await Isolate.run(() async {
      final List<dynamic> completed = [];
      for (var entry in entries) {
        final data = entry.value;
        try {
          final success = await ApiService.submitEvaluation(
            studentId: data['student_id'],
            studentName: data['student_name'] ?? 'Unknown',
            assessmentDetailId: data['assessment_detail_id'],
            obtainedMarks: data['obtained_marks'],
            comments: data['comments'],
            evaluation: data['evaluation'],
            submittedBy: data['submitted_by'] ?? 'unknown',
          );
          if (success) {
            completed.add(entry.key);
          }
        } catch (_) {
          // Failure handled by not adding to completed
        }
      }
      return completed;
    });

    // Back on main thread: update storage
    int successCount = 0;
    for (var key in successKeys) {
      await StorageService.deleteFromQueue(key);
      successCount++;
    }

    int failCount = entries.length - successCount;

    if (failCount == 0) {
      return "Synced $successCount evaluations successfully.";
    } else {
      return "Synced $successCount successfully. Failed to sync $failCount items.";
    }
  }
}
