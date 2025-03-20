import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guide.dart';
import '../providers/book_provider.dart';

class AddGuideScreen extends StatefulWidget {
  const AddGuideScreen({Key? key}) : super(key: key);

  @override
  _AddGuideScreenState createState() => _AddGuideScreenState();
}

class _AddGuideScreenState extends State<AddGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<Map<String, String>> _sections = [{'title': '', 'content': ''}];
  final List<String> _categories = ['Cooking Basics'];
  bool _isFavorite = false;

  final List<String> _categoryOptions = [
    'Cooking Basics',
    'Techniques',
    'Ingredient Guide',
    'Equipment',
    'Food Safety',
    'Meal Planning',
    'Nutrition',
    'Special Diets',
    'Seasonal Cooking',
    'International Cuisine',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addSection() {
    setState(() {
      _sections.add({'title': '', 'content': ''});
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }

  void _updateSectionTitle(int index, String value) {
    setState(() {
      _sections[index]['title'] = value;
    });
  }

  void _updateSectionContent(int index, String value) {
    setState(() {
      _sections[index]['content'] = value;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_categories.contains(category)) {
        _categories.remove(category);
      } else {
        _categories.add(category);
      }
    });
  }

  void _saveGuide() {
    if (_formKey.currentState!.validate()) {
      // Filter out empty sections
      final filteredSections = _sections
          .where((section) =>
      section['title']!.isNotEmpty && section['content']!.isNotEmpty)
          .toList();

      if (filteredSections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one complete section')),
        );
        return;
      }

      final newGuide = Guide(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        sections: filteredSections,
        imageUrl: _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/400x300?text=No+Image'
            : _imageUrlController.text,
        categories: _categories,
        isFavorite: _isFavorite,
        dateAdded: DateTime.now(),
      );

      Provider.of<BookProvider>(context, listen: false).addGuide(newGuide);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cooking Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Guide Title',
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty for placeholder image',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sections',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sections.length,
                itemBuilder: (ctx, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Section ${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _sections.length > 1 ? () => _removeSection(index) : null,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _sections[index]['title'],
                            decoration: const InputDecoration(
                              labelText: 'Section Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_sections[index]['content']!.isNotEmpty && (value == null || value.isEmpty)) {
                                return 'Please enter a section title';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateSectionTitle(index, value),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _sections[index]['content'],
                            decoration: const InputDecoration(
                              labelText: 'Section Content',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (_sections[index]['title']!.isNotEmpty && (value == null || value.isEmpty)) {
                                return 'Please enter section content';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateSectionContent(index, value),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: _addSection,
                icon: const Icon(Icons.add),
                label: const Text('Add Section'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categoryOptions.map((category) {
                  final isSelected = _categories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _toggleCategory(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mark as Favorite'),
                value: _isFavorite,
                onChanged: (bool value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGuide,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Guide'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
