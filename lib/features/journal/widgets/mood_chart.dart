import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/journal_entry.dart';

class MoodChart extends StatelessWidget {
  final Map<MoodType, int> moodDistribution;
  
  const MoodChart({
    Key? key,
    required this.moodDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moodDistribution.isEmpty) {
      return Container(
        height: 200,
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
        child: Center(
          child: Text(
            'No mood data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    
    // Calculate total entries
    final totalEntries = moodDistribution.values.fold(0, (sum, count) => sum + count);
    
    // Prepare pie chart sections
    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];
    
    for (final entry in moodDistribution.entries) {
      final mood = entry.key;
      final count = entry.value;
      final percentage = (count / totalEntries) * 100;
      
      // Create pie section
      sections.add(
        PieChartSectionData(
          color: _getMoodColor(mood),
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      // Create legend item
      legends.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getMoodColor(mood),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMoodText(mood),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '$count entries',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legends,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.amber;
      case MoodType.good:
        return Colors.green;
      case MoodType.neutral:
        return Colors.blue;
      case MoodType.sad:
        return Colors.orange;
      case MoodType.terrible:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  String _getMoodText(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.good:
        return 'Good';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.terrible:
        return 'Terrible';
      default:
        return 'Neutral';
    }
  }
}

