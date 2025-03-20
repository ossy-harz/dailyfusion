import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/timeline_event.dart';
import '../providers/dashboard_provider.dart';

class DailyTimeline extends StatelessWidget {
  const DailyTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final events = dashboardProvider.timelineEvents;
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return TimelineEventItem(event: event);
        },
      ),
    );
  }
}

class TimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
  
  const TimelineEventItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  Color _getEventColor() {
    switch (event.type) {
      case EventType.fitness:
        return AppColors.fitness;
      case EventType.budget:
        return AppColors.budget;
      case EventType.task:
        return AppColors.tasks;
      case EventType.book:
        return AppColors.book;
      case EventType.journal:
        return AppColors.journal;
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case EventType.fitness:
        return Icons.fitness_center;
      case EventType.budget:
        return Icons.account_balance_wallet;
      case EventType.task:
        return Icons.check_circle;
      case EventType.book:
        return Icons.book;
      case EventType.journal:
        return Icons.edit;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor();
    final icon = _getEventIcon();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Text(
              event.timeFormatted,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Timeline line and dot
          Container(
            width: 24,
            height: 80,
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 2,
                  height: 80,
                  color: color.withOpacity(0.3),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          // Event content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (event.progress != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: event.progress,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

