import 'package:connectivity_plus/connectivity_plus.dart';
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

    int successCount = 0;
    int failCount = 0;
    String? lastError;

    // Iterate over copy of keys to avoid modification issues (though getQueueWithKeys returns a new Map)
    final entries = queue.entries.toList();

    for (var entry in entries) {
      final key = entry.key;
      final data = entry.value;

      try {
        final success = await ApiService.submitEvaluation(
          studentId: data['student_id'],
          studentName: data['student_name'] ?? 'Unknown',
          assessmentDetailId: data['assessment_detail_id'],
          obtainedMarks: data['obtained_marks'],
          comments: data['comments'],
          evaluation: data['evaluation'],
        );

        if (success) {
          await StorageService.deleteFromQueue(key);
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        // Keep in queue for retry later
        failCount++;
        lastError = e.toString();
      }
    }

    if (failCount == 0) {
      return "Synced $successCount evaluations successfully.";
    } else {
      return "Synced $successCount successfully. Failed to sync $failCount items. Last Error: $lastError";
    }
  }
}
