import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();
  
  List<JournalEntry> _entries = [];
  
  List<JournalEntry> get entries => _entries;
  
  // Get entries sorted by date (newest first)
  List<JournalEntry> get entriesByDate {
    final sorted = List<JournalEntry>.from(_entries);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
  
  // Get favorite entries
  List<JournalEntry> get favoriteEntries => _entries.where((entry) => entry.isFavorite).toList();
  
  // Get entries by mood
  List<JournalEntry> getEntriesByMood(MoodType mood) {
    return _entries.where((entry) => entry.mood == mood).toList();
  }
  
  // Get entries by tag
  List<JournalEntry> getEntriesByTag(String tag) {
    return _entries.where((entry) => entry.tags.contains(tag)).toList();
  }
  
  // Get entries by date range
  List<JournalEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.date.isAfter(start) && entry.date.isBefore(end);
    }).toList();
  }
  
  // Get mood distribution for analytics
  Map<MoodType, int> get moodDistribution {
    final result = <MoodType, int>{};
    
    for (final entry in _entries) {
      result[entry.mood] = (result[entry.mood] ?? 0) + 1;
    }
    
    return result;
  }
  
  JournalProvider() {
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    try {
      final data = await _storageService.getCollection('journal_entries');
      _entries = data.map((json) => JournalEntry.fromJson(json)).toList();
      
      // If no entries exist, add sample entries
      if (_entries.isEmpty) {
        _addSampleEntries();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      _addSampleEntries();
    }
  }
  
  void _addSampleEntries() {
    final now = DateTime.now();
    
    _entries = [
      JournalEntry(
        id: 'entry-1',
        title: 'A Productive Day',
        content: 'Today was incredibly productive. I managed to complete all the tasks on my to-do list and even had time to go for a run in the evening. I\'m feeling accomplished and motivated to keep up this momentum tomorrow.',
        date: now.subtract(const Duration(days: 1)),
        mood: MoodType.happy,
        tags: ['productivity', 'work', 'exercise'],
      ),
      JournalEntry(
        id: 'entry-2',
        title: 'Feeling Stressed',
        content: 'Work has been overwhelming lately. I have too many deadlines approaching and not enough time. I need to find better ways to manage my time and reduce stress. Perhaps I should try meditation or take short breaks throughout the day.',
        date: now.subtract(const Duration(days: 3)),
        mood: MoodType.sad,
        tags: ['work', 'stress'],
      ),
      JournalEntry(
        id: 'entry-3',
        title: 'Weekend Plans',
        content: 'Looking forward to the weekend. I\'m planning to visit the new art exhibition downtown and then meet friends for dinner. It\'s been a while since I\'ve had time for leisure activities, so this will be a nice change of pace.',
        date: now.subtract(const Duration(days: 5)),
        mood: MoodType.good,
        tags: ['weekend', 'friends', 'art'],
        isFavorite: true,
      ),
    ];
    
    notifyListeners();
  }
  
  Future<void> addEntry(JournalEntry entry) async {
    final newEntry = entry.copyWith(id: _uuid.v4());
    _entries.add(newEntry);
    await _storageService.addDocument('journal_entries', newEntry.toJson());
    notifyListeners();
  }
  
  Future<void> updateEntry(JournalEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      await _storageService.updateDocument('journal_entries', entry.id, entry.toJson());
      notifyListeners();
    }
  }
  
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _storageService.deleteDocument('journal_entries', id);
    notifyListeners();
  }
  
  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      final entry = _entries[index];
      final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
      _entries[index] = updatedEntry;
      await _storageService.updateDocument('journal_entries', id, updatedEntry.toJson());
      notifyListeners();
    }
  }
}

