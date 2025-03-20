import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../screens/journal_entry_detail_screen.dart';
import '../screens/journal_entry_editor_screen.dart';
import 'journal_entry_card.dart';
import 'mood_chart.dart';

class JournalEntryList extends StatelessWidget {
  const JournalEntryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final entries = journalProvider.entriesByDate;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mood analytics
        MoodChart(moodDistribution: journalProvider.moodDistribution),
        
        const SizedBox(height: 24),
        
        // Journal entries
        Text(
          'Journal Entries',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (entries.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No journal entries yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start journaling to track your thoughts and feelings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JournalEntryEditorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JournalEntryDetailScreen(
                          entryId: entry.id,
                        ),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    journalProvider.toggleFavorite(entry.id);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

