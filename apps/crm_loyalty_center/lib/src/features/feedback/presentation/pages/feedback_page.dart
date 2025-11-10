import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Feedback Page - Customer feedback and NPS tracking
class FeedbackPage extends ConsumerWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final feedbacks = [
      Feedback('Sarah J.', 9, 'Great food and service!', DateTime.now().subtract(const Duration(hours: 2)), FeedbackType.nps),
      Feedback('Michael C.', 4, 'Long wait time', DateTime.now().subtract(const Duration(hours: 5)), FeedbackType.complaint),
      Feedback('Emily R.', 10, 'Best restaurant ever!', DateTime.now().subtract(const Duration(days: 1)), FeedbackType.nps),
      Feedback('David K.', 8, 'Good value for money', DateTime.now().subtract(const Duration(days: 2)), FeedbackType.nps),
    ];

    final npsScore = feedbacks.where((f) => f.type == FeedbackType.nps).fold<double>(0, (sum, f) => sum + f.rating) /
                     feedbacks.where((f) => f.type == FeedbackType.nps).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // NPS Score Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Promoter Score',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          npsScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'out of 10',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: [
                          PieChartSectionData(value: 60, color: Colors.green, title: '60%', radius: 20),
                          PieChartSectionData(value: 25, color: Colors.orange, title: '25%', radius: 20),
                          PieChartSectionData(value: 15, color: Colors.red, title: '15%', radius: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sentiment Breakdown
          Row(
            children: [
              Expanded(child: _buildSentimentCard(theme, 'Promoters', '60%', Colors.green, Icons.thumb_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildSentimentCard(theme, 'Passive', '25%', Colors.orange, Icons.thumbs_up_down)),
              const SizedBox(width: 12),
              Expanded(child: _buildSentimentCard(theme, 'Detractors', '15%', Colors.red, Icons.thumb_down)),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Feedback
          Text(
            'Recent Feedback',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...feedbacks.map((feedback) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getRatingColor(feedback.rating).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    feedback.rating.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(feedback.rating),
                    ),
                  ),
                ),
              ),
              title: Text(feedback.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feedback.comment),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, h:mm a').format(feedback.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: feedback.type == FeedbackType.complaint ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: feedback.type == FeedbackType.complaint ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(ThemeData theme, String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 9) return Colors.green;
    if (rating >= 7) return Colors.orange;
    return Colors.red;
  }
}

class Feedback {
  final String customerName;
  final int rating;
  final String comment;
  final DateTime date;
  final FeedbackType type;
  Feedback(this.customerName, this.rating, this.comment, this.date, this.type);
}

enum FeedbackType { nps, complaint, compliment }
