import 'package:flutter/material.dart';

import '../widgets/task_calendar.dart';
import '../widgets/task_kanban.dart';
import '../widgets/task_list.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks & Projects'),
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List'),
              Tab(text: 'Kanban'),
              Tab(text: 'Calendar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // List View
            const Padding(
              padding: EdgeInsets.all(16),
              child: TaskList(),
            ),
            
            // Kanban View
            const Padding(
              padding: EdgeInsets.all(16),
              child: TaskKanban(),
            ),
            
            // Calendar View
            const Padding(
              padding: EdgeInsets.all(16),
              child: TaskCalendar(),
            ),
          ],
        ),
      ),
    );
  }
}

