import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screens (adjust these imports based on your project structure)
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/fitness/screens/fitness_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/book/screens/book_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Main routes with a persistent bottom navigation bar
    ShellRoute(
      builder: (context, state, child) {
        // Calculate the current index based on the location.
        final int currentIndex = _calculateSelectedIndex(state.uri.toString());
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              // Navigate using the route names
              switch (index) {
                case 0:
                  context.goNamed('dashboard');
                  break;
                case 1:
                  context.goNamed('fitness');
                  break;
                case 2:
                  context.goNamed('budget');
                  break;
                case 3:
                  context.goNamed('tasks');
                  break;
                case 4:
                  context.goNamed('book');
                  break;
                default:
                  context.goNamed('dashboard');
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                label: 'Fitness',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Budget',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                label: 'Book',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/fitness',
          name: 'fitness',
          builder: (context, state) => const FitnessScreen(),
        ),
        GoRoute(
          path: '/budget',
          name: 'budget',
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: '/tasks',
          name: 'tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/book',
          name: 'book',
          builder: (context, state) => const BookScreen(),
        ),
        GoRoute(
          path: '/journal',
          name: 'journal',
          builder: (context, state) => const JournalScreen(),
        ),
      ],
    ),
    // Routes that don't require the bottom navigation (or need a different layout)
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);

// A helper function to determine the selected index based on the current location.
int _calculateSelectedIndex(String location) {
  if (location.startsWith('/fitness')) return 1;
  if (location.startsWith('/budget')) return 2;
  if (location.startsWith('/tasks')) return 3;
  if (location.startsWith('/book')) return 4;
  // Default to dashboard if no other route matches.
  return 0;
}
