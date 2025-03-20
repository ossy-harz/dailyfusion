import 'package:flutter/material.dart';
import '../models/guide.dart';
import 'guide_card.dart';

class GuideList extends StatelessWidget {
  final List<Guide> guides;
  final Future<void> Function() onRefresh;
  final Function(Guide) onTap;

  const GuideList({
    Key? key,
    required this.guides,
    required this.onRefresh,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No guides yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first cooking guide',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        itemBuilder: (ctx, index) {
          final guide = guides[index];
          return GuideCard(
            guide: guide,
            onTap: () => onTap(guide),
          );
        },
      ),
    );
  }
}
