import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';


class AnimatedFabMenu extends StatefulWidget {
  const AnimatedFabMenu({Key? key}) : super(key: key);

  @override
  State<AnimatedFabMenu> createState() => _AnimatedFabMenuState();
}

class _AnimatedFabMenuState extends State<AnimatedFabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FlowMenuDelegate(
        animation: _animationController,
      ),
      children: [
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
          ),
        ),
        // Add Task
        FloatingActionButton(
          onPressed: () {
            _toggle();
            // Navigate to add task
            context.push('/tasks/add');
          },
          backgroundColor: AppColors.tasks,
          child: const Icon(Icons.check),
        ),
        // Add Workout
        FloatingActionButton(
          onPressed: () {
            _toggle();
            // Navigate to add workout
            context.push('/fitness/add');
          },
          backgroundColor: AppColors.fitness,
          child: const Icon(Icons.fitness_center),
        ),
        // Add Expense
        FloatingActionButton(
          onPressed: () {
            _toggle();
            // Navigate to add expense
            context.push('/budget/add');
          },
          backgroundColor: AppColors.budget,
          child: const Icon(Icons.account_balance_wallet),
        ),
        // Add to Book
        FloatingActionButton(
          onPressed: () {
            _toggle();
            // Navigate to add to book
            context.push('/book/add');
          },
          backgroundColor: AppColors.book,
          child: const Icon(Icons.book),
        ),
        // Add Journal Entry
        FloatingActionButton(
          onPressed: () {
            _toggle();
            // Navigate to add journal entry
            context.push('/journal/add');
          },
          backgroundColor: AppColors.journal,
          child: const Icon(Icons.edit),
        ),
      ],
    );
  }
}

class FlowMenuDelegate extends FlowDelegate {
  final Animation<double> animation;
  
  FlowMenuDelegate({required this.animation}) : super(repaint: animation);
  
  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - 56;
    final yStart = size.height - 56;
    
    final buttonCount = context.childCount;
    final lastIndex = buttonCount - 1;
    
    for (int i = lastIndex; i >= 0; i--) {
      final childSize = context.getChildSize(i)!.width;
      
      final dx = xStart;
      final dy = yStart - (i * (childSize + 12) * animation.value);
      
      context.paintChild(
        i,
        transform: Matrix4.translationValues(dx, dy, 0),
        opacity: i == lastIndex ? 1.0 : animation.value,
      );
    }
  }

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

