import 'package:flutter/material.dart';
import '../model/assessment_detail_model.dart';
import '../services/api_service.dart';
import 'evaluation_form_screen.dart';

class AssessmentDetailsScreen extends StatefulWidget {
  final int assessmentId;
  final String assessmentTitle;

  const AssessmentDetailsScreen({
    Key? key,
    required this.assessmentId,
    required this.assessmentTitle,
  }) : super(key: key);

  @override
  State<AssessmentDetailsScreen> createState() => _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<AssessmentDetailsScreen> {
  late Future<List<AssessmentDetail>> detailsFuture;

  @override
  void initState() {
    super.initState();
    detailsFuture = ApiService.getAssessmentDetails(widget.assessmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assessmentTitle),
      ),
      body: FutureBuilder<List<AssessmentDetail>>(
        future: detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }
          final details = snapshot.data ?? [];
          if (details.isEmpty) {
            return const Center(child: Text('No details found for this assessment'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(detail.description, style: const TextStyle(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marks: ${detail.totalMarks}', style: const TextStyle(color: Colors.white70)),
                            // Text('Is Comment: ${detail.isComment}', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EvaluationFormScreen(
                            assessmentId: widget.assessmentId,
                            assessmentTitle: widget.assessmentTitle,
                            // details: details,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Now'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
