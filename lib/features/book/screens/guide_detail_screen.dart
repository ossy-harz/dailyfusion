import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guide.dart';
import '../providers/book_provider.dart';

class GuideDetailScreen extends StatefulWidget {
  final String guideId;

  const GuideDetailScreen({Key? key, required this.guideId}) : super(key: key);

  @override
  _GuideDetailScreenState createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  Guide? _guide;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    setState(() {
      _isLoading = true;
    });

    final guide = await Provider.of<BookProvider>(context, listen: false)
        .getGuideById(widget.guideId);

    setState(() {
      _guide = guide;
      _isLoading = false;
    });
  }

  void _showEditDialog() {
    if (_guide == null) return;

    final titleController = TextEditingController(text: _guide!.title);
    final descriptionController = TextEditingController(text: _guide!.description);
    final imageUrlController = TextEditingController(text: _guide!.imageUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Guide'),
        content: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 5,
                ),
                TextFormField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedGuide = _guide!.copyWith(
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: imageUrlController.text,
              );

              await Provider.of<BookProvider>(context, listen: false)
                  .updateGuide(updatedGuide);

              Navigator.of(context).pop();
              _loadGuide();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Guide'),
        content: const Text('Are you sure you want to delete this guide?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<BookProvider>(context, listen: false)
                  .deleteGuide(widget.guideId);

              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_guide == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guide Not Found')),
        body: const Center(child: Text('Guide not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_guide!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _guide!.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, _) => Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey,
                child: const Center(child: Text('Image not available')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _guide!.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: _guide!.categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _guide!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
