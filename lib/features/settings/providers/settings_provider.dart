import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_profile.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  UserProfile? _userProfile;
  bool _isLoggedIn = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoggedIn => _isLoggedIn;

  // Convert our stored AppThemeMode to Flutter's ThemeMode.
  ThemeMode get themeMode {
    final appTheme = _userProfile?.appThemeMode ?? AppThemeMode.system;
    switch (appTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  bool get useOfflineMode => _userProfile?.useOfflineMode ?? false;
  bool get enableNotifications => _userProfile?.enableNotifications ?? true;

  Map<String, bool> get moduleVisibility =>
      _userProfile?.moduleVisibility ?? {
        'dashboard': true,
        'fitness': true,
        'budget': true,
        'tasks': true,
        'book': true,
        'journal': true,
      };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (_isLoggedIn) {
        final userId = prefs.getString('userId');
        if (userId != null) {
          final userData = await _storageService.getDocument('users', userId);
          if (userData != null) {
            _userProfile = UserProfile.fromJson(userData);
          } else {
            _createDefaultProfile(userId);
          }
        }
      } else {
        // Create a default profile for non-logged in users
        _createDefaultProfile('guest');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _createDefaultProfile('guest');
      notifyListeners();
    }
  }

  void _createDefaultProfile(String userId) {
    _userProfile = UserProfile(
      id: userId,
      appThemeMode: AppThemeMode.system,
      useOfflineMode: false,
      enableNotifications: true,
      moduleVisibility: {
        'dashboard': true,
        'fitness': true,
        'budget': true,
        'tasks': true,
        'book': true,
        'journal': true,
      },
      preferences: {},
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    // Map Flutter's ThemeMode to our AppThemeMode.
    AppThemeMode newAppTheme;
    switch (mode) {
      case ThemeMode.light:
        newAppTheme = AppThemeMode.light;
        break;
      case ThemeMode.dark:
        newAppTheme = AppThemeMode.dark;
        break;
      case ThemeMode.system:
      default:
        newAppTheme = AppThemeMode.system;
        break;
    }

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(appThemeMode: newAppTheme);
      _userProfile = updatedProfile;

      if (_isLoggedIn) {
        await _storageService.updateDocument(
            'users', updatedProfile.id, updatedProfile.toJson());
      }

      notifyListeners();
    }
  }

  Future<void> updateOfflineMode(bool useOffline) async {
    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(useOfflineMode: useOffline);
      _userProfile = updatedProfile;

      if (_isLoggedIn) {
        await _storageService.updateDocument(
            'users', updatedProfile.id, updatedProfile.toJson());
      }

      notifyListeners();
    }
  }

  Future<void> updateNotifications(bool enableNotifs) async {
    if (_userProfile != null) {
      final updatedProfile =
      _userProfile!.copyWith(enableNotifications: enableNotifs);
      _userProfile = updatedProfile;

      if (_isLoggedIn) {
        await _storageService.updateDocument(
            'users', updatedProfile.id, updatedProfile.toJson());
      }

      notifyListeners();
    }
  }

  Future<void> updateModuleVisibility(String module, bool isVisible) async {
    if (_userProfile != null) {
      final updatedVisibility =
      Map<String, bool>.from(_userProfile!.moduleVisibility);
      updatedVisibility[module] = isVisible;

      final updatedProfile =
      _userProfile!.copyWith(moduleVisibility: updatedVisibility);
      _userProfile = updatedProfile;

      if (_isLoggedIn) {
        await _storageService.updateDocument(
            'users', updatedProfile.id, updatedProfile.toJson());
      }

      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;

    if (_isLoggedIn) {
      await _storageService.updateDocument(
          'users', profile.id, profile.toJson());
    }

    notifyListeners();
  }

  Future<void> login(
      String userId, String email, String displayName, String? photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);

    // Check if user profile exists
    final userData = await _storageService.getDocument('users', userId);
    if (userData != null) {
      _userProfile = UserProfile.fromJson(userData);
    } else {
      // Create new user profile
      _userProfile = UserProfile(
        id: userId,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        appThemeMode: AppThemeMode.system,
        useOfflineMode: false,
        enableNotifications: true,
        moduleVisibility: {
          'dashboard': true,
          'fitness': true,
          'budget': true,
          'tasks': true,
          'book': true,
          'journal': true,
        },
        preferences: {},
      );

      await _storageService.addDocument('users', _userProfile!.toJson());
    }

    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');

    _isLoggedIn = false;
    _createDefaultProfile('guest');

    notifyListeners();
  }
}
