import 'package:dailyfusion/core/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/book/providers/book_provider.dart';
import '../../features/budget/providers/budget_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/fitness/providers/fitness_provider.dart';
import '../../features/journal/providers/journal_provider.dart';
import '../../features/tasks/providers/tasks_provider.dart';


final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => DashboardProvider()),
  ChangeNotifierProvider(create: (_) => FitnessProvider()),
  ChangeNotifierProvider(create: (_) => BudgetProvider()),
  ChangeNotifierProvider(create: (_) => TasksProvider()),
  ChangeNotifierProvider(create: (_) => BookProvider()),
  ChangeNotifierProvider(create: (_) => JournalProvider()),
];

