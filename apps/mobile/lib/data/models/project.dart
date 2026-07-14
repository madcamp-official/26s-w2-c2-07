enum ProjectStatus { active, done, archived }

ProjectStatus projectStatusFromString(String value) {
  return ProjectStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ProjectStatus.active,
  );
}

class Project {
  const Project({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => status == ProjectStatus.done;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: projectStatusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
