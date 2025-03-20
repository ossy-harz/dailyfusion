import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';

class TaskKanban extends StatelessWidget {
  const TaskKanban({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    
    final todoTasks = tasksProvider.getTasksByStatus(TaskStatus.todo);
    final inProgressTasks = tasksProvider.getTasksByStatus(TaskStatus.inProgress);
    final completedTasks = tasksProvider.getTasksByStatus(TaskStatus.completed);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 3 * 280, // 3 columns of 280px width
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // To Do column
            _KanbanColumn(
              title: 'To Do',
              tasks: todoTasks,
              status: TaskStatus.todo,
              color: Colors.orange,
            ),
            
            // In Progress column
            _KanbanColumn(
              title: 'In Progress',
              tasks: inProgressTasks,
              status: TaskStatus.inProgress,
              color: Colors.purple,
            ),
            
            // Completed column
            _KanbanColumn(
              title: 'Completed',
              tasks: completedTasks,
              status: TaskStatus.completed,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final TaskStatus status;
  final Color color;
  
  const _KanbanColumn({
    Key? key,
    required this.title,
    required this.tasks,
    required this.status,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Task cards
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _KanbanCard(task: tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  
  const _KanbanCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(context),
      ),
      child: DragTarget<Task>(
        onWillAccept: (incomingTask) => incomingTask?.id != task.id,
        onAccept: (incomingTask) {
          // Handle reordering logic here
        },
        builder: (context, candidateData, rejectedData) {
          return _buildCard(context);
        },
      ),
    );
  }
  
  Widget _buildCard(BuildContext context) {
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
              
              const SizedBox(height: 8),
              
              // Task title
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium,
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
                    '${task.dueDate.day}/${task.dueDate.month}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: task.isOverdue
                          ? Colors.red
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  
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

