import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';

class TaskList extends StatelessWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final tasks = tasksProvider.tasks;
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group tasks by status
    final todoTasks = tasksProvider.getTasksByStatus(TaskStatus.todo);
    final inProgressTasks = tasksProvider.getTasksByStatus(TaskStatus.inProgress);
    final completedTasks = tasksProvider.getTasksByStatus(TaskStatus.completed);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overdue tasks
          if (tasksProvider.overdueTasks.isNotEmpty) ...[
            _TaskSection(
              title: 'Overdue',
              tasks: tasksProvider.overdueTasks,
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 24),
          ],
          
          // Today's tasks
          if (tasksProvider.tasksForToday.isNotEmpty) ...[
            _TaskSection(
              title: 'Today',
              tasks: tasksProvider.tasksForToday,
              icon: Icons.today,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 24),
          ],
          
          // To-do tasks
          if (todoTasks.isNotEmpty) ...[
            _TaskSection(
              title: 'To Do',
              tasks: todoTasks,
              icon: Icons.check_circle_outline,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 24),
          ],
          
          // In progress tasks
          if (inProgressTasks.isNotEmpty) ...[
            _TaskSection(
              title: 'In Progress',
              tasks: inProgressTasks,
              icon: Icons.pending_actions,
              iconColor: Colors.purple,
            ),
            const SizedBox(height: 24),
          ],
          
          // Completed tasks
          if (completedTasks.isNotEmpty) ...[
            _TaskSection(
              title: 'Completed',
              tasks: completedTasks,
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final IconData icon;
  final Color iconColor;
  
  const _TaskSection({
    Key? key,
    required this.title,
    required this.tasks,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${tasks.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskListItem(task: tasks[index]);
          },
        ),
      ],
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  
  const TaskListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to task details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  InkWell(
                    onTap: () {
                      if (task.status == TaskStatus.completed) {
                        tasksProvider.updateTaskStatus(task.id, TaskStatus.todo);
                      } else {
                        tasksProvider.updateTaskStatus(task.id, TaskStatus.completed);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.status == TaskStatus.completed
                            ? task.getPriorityColor()
                            : Colors.transparent,
                        border: Border.all(
                          color: task.getPriorityColor(),
                          width: 2,
                        ),
                      ),
                      child: task.status == TaskStatus.completed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Task title
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.completed
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                  ),
                  
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.getPriorityText(),
                      style: TextStyle(
                        color: task.getPriorityColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Task metadata
              Row(
                children: [
                  // Due date
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: task.isOverdue
                        ? Colors.red
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(task.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: task.isOverdue
                          ? Colors.red
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Project (if any)
                  if (task.projectId != null) ...[
                    const Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tasksProvider.projects
                          .firstWhere((p) => p.id == task.projectId)
                          .name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Subtasks (if any)
                  if (task.subTasks.isNotEmpty) ...[
                    Text(
                      '${task.subTasks.where((st) => st.isCompleted).length}/${task.subTasks.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              
              // Progress bar for subtasks
              if (task.subTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: task.getPriorityColor().withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(task.getPriorityColor()),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 4,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

