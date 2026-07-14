class ProfileSettings {
  const ProfileSettings({
    required this.captureAlertsEnabled,
    required this.darkEditorEnabled,
  });

  final bool captureAlertsEnabled;
  final bool darkEditorEnabled;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    return ProfileSettings(
      captureAlertsEnabled: json['captureAlertsEnabled'] as bool? ?? false,
      darkEditorEnabled: json['darkEditorEnabled'] as bool? ?? false,
    );
  }
}

class Profile {
  const Profile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    required this.provider,
    required this.createdAt,
    required this.settings,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String provider;
  final DateTime createdAt;
  final ProfileSettings settings;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      provider: json['provider'] as String? ?? 'email',
      createdAt: DateTime.parse(json['created_at'] as String),
      settings: ProfileSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
