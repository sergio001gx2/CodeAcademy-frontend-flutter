class Progress {
  final int id;
  final int enrollment;
  final int lesson;
  final bool completed;
  final DateTime? completedAt;

  Progress({
    required this.id,
    required this.enrollment,
    required this.lesson,
    required this.completed,
    this.completedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] as int,
      enrollment: json['enrollment'] as int,
      lesson: json['lesson'] as int,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
