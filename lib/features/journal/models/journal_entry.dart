import 'package:flutter/material.dart';

enum MoodType {
  happy,
  good,
  neutral,
  sad,
  terrible
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final MoodType mood;
  final List<String> tags;
  final List<String>? imageUrls;
  final bool isFavorite;
  
  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.tags = const [],
    this.imageUrls,
    this.isFavorite = false,
  });
  
  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    MoodType? mood,
    List<String>? tags,
    List<String>? imageUrls,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood.toString(),
      'tags': tags,
      'imageUrls': imageUrls,
      'isFavorite': isFavorite,
    };
  }
  
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      mood: MoodType.values.firstWhere(
        (e) => e.toString() == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
  
  String getMoodText() {
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
      }
  }
  
  IconData getMoodIcon() {
    switch (mood) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.good:
        return Icons.sentiment_satisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.terrible:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
  
  Color getMoodColor() {
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
}

