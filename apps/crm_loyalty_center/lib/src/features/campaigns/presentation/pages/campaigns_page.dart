import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Campaigns Page - Marketing campaign management
class CampaignsPage extends ConsumerWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final campaigns = [
      Campaign('Weekend Special', CampaignType.push, CampaignStatus.active, 1250, DateTime.now()),
      Campaign('Loyalty Reminder', CampaignType.email, CampaignStatus.scheduled, 0, DateTime.now().add(const Duration(days: 2))),
      Campaign('New Menu Items', CampaignType.sms, CampaignStatus.draft, 0, null),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campaigns')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(_getCampaignIcon(campaign.type), size: 32),
              title: Text(campaign.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${campaign.type.name.toUpperCase()} • ${campaign.status.name.toUpperCase()}'),
                  if (campaign.status == CampaignStatus.active)
                    Text('Sent to ${campaign.sentCount} customers'),
                  if (campaign.status == CampaignStatus.scheduled)
                    Text('Scheduled: ${DateFormat('MMM dd, h:mm a').format(campaign.scheduledDate!)}'),
                ],
              ),
              trailing: _buildStatusChip(campaign.status),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
    );
  }

  IconData _getCampaignIcon(CampaignType type) {
    switch (type) {
      case CampaignType.push: return Icons.notifications;
      case CampaignType.email: return Icons.email;
      case CampaignType.sms: return Icons.sms;
    }
  }

  Widget _buildStatusChip(CampaignStatus status) {
    Color color;
    switch (status) {
      case CampaignStatus.active: color = Colors.green; break;
      case CampaignStatus.scheduled: color = Colors.blue; break;
      case CampaignStatus.draft: color = Colors.grey; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class Campaign {
  final String name;
  final CampaignType type;
  final CampaignStatus status;
  final int sentCount;
  final DateTime? scheduledDate;
  Campaign(this.name, this.type, this.status, this.sentCount, this.scheduledDate);
}

enum CampaignType { push, email, sms }
enum CampaignStatus { active, scheduled, draft }
