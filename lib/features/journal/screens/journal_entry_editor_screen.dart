import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalEntryEditorScreen extends StatefulWidget {
  final String? entryId;
  
  const JournalEntryEditorScreen({
    Key? key,
    this.entryId,
  }) : super(key: key);

  @override
  State<JournalEntryEditorScreen> createState() => _JournalEntryEditorScreenState();
}

class _JournalEntryEditorScreenState extends State<JournalEntryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  
  late MoodType _selectedMood;
  final List<String> _tags = [];
  bool _isFavorite = false;
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _selectedMood = MoodType.neutral;
    
    // If entryId is provided, load the entry for editing
    if (widget.entryId != null) {
      _isEditing = true;
      _loadEntry();
    }
  }
  
  void _loadEntry() {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final entry = journalProvider.entries.firstWhere((e) => e.id == widget.entryId);
    
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    _selectedMood = entry.mood;
    _tags.addAll(entry.tags);
    _isFavorite = entry.isFavorite;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      if (_isEditing) {
        // Update existing entry
        final entry = journalProvider.entries.firstWhere((e) => e.id == widget.entryId);
        final updatedEntry = entry.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          mood: _selectedMood,
          tags: _tags,
          isFavorite: _isFavorite,
        );
        
        await journalProvider.updateEntry(updatedEntry);
      } else {
        // Create new entry
        final newEntry = JournalEntry(
          id: const Uuid().v4(),
          title: _titleController.text,
          content: _contentController.text,
          date: DateTime.now(),
          mood: _selectedMood,
          tags: _tags,
          isFavorite: _isFavorite,
        );
        
        await journalProvider.addEntry(newEntry);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Journal Entry' : 'New Journal Entry'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood selector
                    Text(
                      'How are you feeling?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: MoodType.values.map((mood) {
                        final isSelected = mood == _selectedMood;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _getMoodColor(mood)
                                      : _getMoodColor(mood).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getMoodIcon(mood),
                                  color: isSelected
                                      ? Colors.white
                                      : _getMoodColor(mood),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getMoodText(mood),
                                style: TextStyle(
                                  color: isSelected
                                      ? _getMoodColor(mood)
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Content field
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Write your thoughts...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some content';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tags
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add a tag',
                              prefixIcon: Icon(Icons.tag),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addTag,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.journal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Add images button (placeholder)
                    OutlinedButton.icon(
                      onPressed: () {
                        // Add images functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image upload coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Add Images'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
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
  
  IconData _getMoodIcon(MoodType mood) {
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

