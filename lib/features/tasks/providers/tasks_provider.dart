import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/task.dart';

class TasksProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();
  
  List<Task> _tasks = [];
  List<Project> _projects = [];
  
  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  
  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }
  
  // Get tasks by project
  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }
  
  // Get tasks due today
  List<Task> get tasksForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(today) && task.status != TaskStatus.completed;
    }).toList();
  }
  
  // Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isBefore(today) && task.status != TaskStatus.completed;
    }).toList();
  }
  
  TasksProvider() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final taskData = await _storageService.getCollection('tasks');
      _tasks = taskData.map((json) => Task.fromJson(json)).toList();
      
      final projectData = await _storageService.getCollection('projects');
      _projects = projectData.map((json) => Project.fromJson(json)).toList();
      
      // If no data exists, add sample data
      if (_tasks.isEmpty) {
        _addSampleData();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading task data: $e');
      _addSampleData();
    }
  }
  
  void _addSampleData() {
    // Sample projects
    _projects = [
      Project(
        id: 'project-1',
        name: 'Work',
        description: 'Work-related tasks',
        color: Colors.blue,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 'project-2',
        name: 'Personal',
        description: 'Personal tasks',
        color: Colors.green,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 'project-3',
        name: 'Home',
        description: 'Home-related tasks',
        color: Colors.orange,
        createdAt: DateTime.now(),
      ),
    ];
    
    // Sample tasks
    _tasks = [
      Task(
        id: 'task-1',
        title: 'Complete project proposal',
        description: 'Finish the proposal for the new client project',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        tags: ['work', 'client'],
        projectId: 'project-1',
        subTasks: [
          SubTask(
            id: 'subtask-1',
            title: 'Research competitors',
            isCompleted: true,
          ),
          SubTask(
            id: 'subtask-2',
            title: 'Create outline',
            isCompleted: true,
          ),
          SubTask(
            id: 'subtask-3',
            title: 'Write first draft',
            isCompleted: false,
          ),
          SubTask(
            id: 'subtask-4',
            title: 'Review with team',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task-2',
        title: 'Grocery shopping',
        description: 'Buy groceries for the week',
        dueDate: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        tags: ['personal', 'shopping'],
        projectId: 'project-2',
        subTasks: [
          SubTask(
            id: 'subtask-1',
            title: 'Make shopping list',
            isCompleted: true,
          ),
          SubTask(
            id: 'subtask-2',
            title: 'Check pantry',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task-3',
        title: 'Fix leaking faucet',
        description: 'Call plumber or DIY',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        priority: TaskPriority.urgent,
        status: TaskStatus.todo,
        tags: ['home', 'repair'],
        projectId: 'project-3',
      ),
      Task(
        id: 'task-4',
        title: 'Weekly team meeting',
        description: 'Discuss project progress and roadblocks',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        tags: ['work', 'meeting'],
        projectId: 'project-1',
        isRecurring: true,
        recurringPattern: 'weekly',
      ),
      Task(
        id: 'task-5',
        title: 'Pay utility bills',
        description: 'Pay electricity, water, and internet bills',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        tags: ['personal', 'finance'],
        projectId: 'project-2',
      ),
    ];
    
    notifyListeners();
  }
  
  Future<void> addTask(Task task) async {
    final newTask = task.copyWith(id: _uuid.v4());
    _tasks.add(newTask);
    await _storageService.addDocument('tasks', newTask.toJson());
    notifyListeners();
  }
  
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _storageService.updateDocument('tasks', task.id, task.toJson());
      notifyListeners();
    }
  }
  
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _storageService.deleteDocument('tasks', id);
    notifyListeners();
  }
  
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(status: status);
      _tasks[index] = updatedTask;
      await _storageService.updateDocument('tasks', id, updatedTask.toJson());
      notifyListeners();
    }
  }
  
  Future<void> toggleSubTaskCompletion(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
      
      if (subTaskIndex != -1) {
        final subTask = task.subTasks[subTaskIndex];
        final updatedSubTasks = List<SubTask>.from(task.subTasks);
        updatedSubTasks[subTaskIndex] = subTask.copyWith(isCompleted: !subTask.isCompleted);
        
        final updatedTask = task.copyWith(subTasks: updatedSubTasks);
        _tasks[taskIndex] = updatedTask;
        
        await _storageService.updateDocument('tasks', taskId, updatedTask.toJson());
        notifyListeners();
      }
    }
  }
  
  Future<void> addProject(Project project) async {
    final newProject = Project(
      id: _uuid.v4(),
      name: project.name,
      description: project.description,
      color: project.color,
      createdAt: DateTime.now(),
      dueDate: project.dueDate,
    );
    
    _projects.add(newProject);
    await _storageService.addDocument('projects', newProject.toJson());
    notifyListeners();
  }
  
  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _storageService.updateDocument('projects', project.id, project.toJson());
      notifyListeners();
    }
  }
  
  Future<void> deleteProject(String id) async {
    // Delete all tasks associated with this project
    final tasksToDelete = _tasks.where((task) => task.projectId == id).toList();
    for (final task in tasksToDelete) {
      await deleteTask(task.id);
    }
    
    _projects.removeWhere((project) => project.id == id);
    await _storageService.deleteDocument('projects', id);
    notifyListeners();
  }
}

