/// Todo item with title, description, duration and status.
class TodoModel {
  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.status = TodoStatus.todo,
    this.elapsedSeconds = 0,
    this.timerStartedAt,
    this.timerRunStartElapsed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  TodoStatus status;
  int elapsedSeconds;
  /// When set, timer is "running" (even in background). Elapsed = timerRunStartElapsed + (now - timerStartedAt).
  DateTime? timerStartedAt;
  int? timerRunStartElapsed;
  final DateTime createdAt;

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    int? durationSeconds,
    TodoStatus? status,
    int? elapsedSeconds,
    DateTime? timerStartedAt,
    int? timerRunStartElapsed,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      timerRunStartElapsed: timerRunStartElapsed ?? this.timerRunStartElapsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'status': status.name,
      'elapsedSeconds': elapsedSeconds,
      'timerStartedAt': timerStartedAt?.toIso8601String(),
      'timerRunStartElapsed': timerRunStartElapsed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationSeconds: json['durationSeconds'] as int,
      status: TodoStatus.values.byName(json['status'] as String),
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      timerStartedAt: json['timerStartedAt'] != null
          ? DateTime.parse(json['timerStartedAt'] as String)
          : null,
      timerRunStartElapsed: json['timerRunStartElapsed'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

enum TodoStatus {
  todo,
  inProgress,
  done,
}
