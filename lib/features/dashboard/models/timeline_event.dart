enum EventType {
  fitness,
  budget,
  task,
  book,
  journal,
  other,
}

class TimelineEvent {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final EventType type;
  final double? progress;
  
  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.progress,
  });
  
  String get timeFormatted {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

