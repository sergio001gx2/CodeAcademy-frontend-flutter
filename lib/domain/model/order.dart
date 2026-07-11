class Order {
  final int id;
  final int student;
  final int course;
  final String courseTitle;
  final DateTime enrolledAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.student,
    required this.course,
    required this.courseTitle,
    required this.enrolledAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      student: json['student'] as int? ?? 0,
      course: json['course'] as int,
      courseTitle: json['course_title'] as String? ?? '',
      enrolledAt: json['enrolled_at'] != null 
          ? DateTime.parse(json['enrolled_at']) 
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'course': course,
      'course_title': courseTitle,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
