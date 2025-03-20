import 'package:flutter/material.dart';

import '../widgets/journal_entry_list.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal & Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: JournalEntryList(),
      ),
    );
  }
}

