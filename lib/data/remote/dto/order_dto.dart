import 'package:codeacademy/domain/model/order.dart';

class OrderDto {
  final int id;
  final int student;
  final int course;
  final String courseTitle;
  final String enrolledAt;
  final String? completedAt;

  OrderDto({
    required this.id,
    required this.student,
    required this.course,
    required this.courseTitle,
    required this.enrolledAt,
    this.completedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as int,
      student: json['student'] as int? ?? 0,
      course: json['course'] as int,
      courseTitle: json['course_title'] as String? ?? '',
      enrolledAt: json['enrolled_at'] as String? ?? '',
      completedAt: json['completed_at'] as String?,
    );
  }

  Order toDomain() {
    return Order(
      id: id,
      student: student,
      course: course,
      courseTitle: courseTitle,
      enrolledAt: DateTime.tryParse(enrolledAt) ?? DateTime.now(),
      completedAt: completedAt != null ? DateTime.tryParse(completedAt!) : null,
    );
  }
}
