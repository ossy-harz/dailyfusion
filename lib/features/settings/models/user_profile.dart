enum AppThemeMode {
  light,
  dark,
  system
}

class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final AppThemeMode appThemeMode;
  final bool useOfflineMode;
  final bool enableNotifications;
  final Map<String, bool> moduleVisibility;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.appThemeMode = AppThemeMode.system,
    this.useOfflineMode = false,
    this.enableNotifications = true,
    this.moduleVisibility = const {
      'dashboard': true,
      'fitness': true,
      'budget': true,
      'tasks': true,
      'book': true,
      'journal': true,
    },
    this.preferences = const {},
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    AppThemeMode? appThemeMode,
    bool? useOfflineMode,
    bool? enableNotifications,
    Map<String, bool>? moduleVisibility,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      appThemeMode: appThemeMode ?? this.appThemeMode,
      useOfflineMode: useOfflineMode ?? this.useOfflineMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      moduleVisibility: moduleVisibility ?? this.moduleVisibility,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'appThemeMode': appThemeMode.toString(),
      'useOfflineMode': useOfflineMode,
      'enableNotifications': enableNotifications,
      'moduleVisibility': moduleVisibility,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      appThemeMode: AppThemeMode.values.firstWhere(
            (e) => e.toString() == json['appThemeMode'],
        orElse: () => AppThemeMode.system,
      ),
      useOfflineMode: json['useOfflineMode'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      moduleVisibility: json['moduleVisibility'] != null
          ? Map<String, bool>.from(json['moduleVisibility'])
          : {
        'dashboard': true,
        'fitness': true,
        'budget': true,
        'tasks': true,
        'book': true,
        'journal': true,
      },
      preferences: json['preferences'] ?? {},
    );
  }
}
