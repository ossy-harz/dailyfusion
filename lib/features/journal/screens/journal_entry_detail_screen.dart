import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/journal_provider.dart';
import 'journal_entry_editor_screen.dart';

class JournalEntryDetailScreen extends StatelessWidget {
  final String entryId;
  
  const JournalEntryDetailScreen({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final entry = journalProvider.entries.firstWhere((e) => e.id == entryId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM d, yyyy').format(entry.date)),
        actions: [
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: entry.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              journalProvider.toggleFavorite(entry.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit entry screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalEntryEditorScreen(
                    entryId: entry.id,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Show delete confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        journalProvider.deleteEntry(entry.id);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to journal list
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: entry.getMoodColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    entry.getMoodIcon(),
                    color: entry.getMoodColor(),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeling ${entry.getMoodText()}',
                      style: TextStyle(
                        color: entry.getMoodColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy - h:mm a').format(entry.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Entry title
            Text(
              entry.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Entry content
            Text(
              entry.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            // Images if any
            if (entry.imageUrls != null && entry.imageUrls!.isNotEmpty) ...[
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entry.imageUrls!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Show full-screen image
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        entry.imageUrls![index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ],
            
            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

