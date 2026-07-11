class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int course;
  final int student;
  final String? studentEmail;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.course,
    required this.student,
    this.studentEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      course: json['course'] as int,
      student: json['student'] as int? ?? 0,
      studentEmail: json['student_email'] as String?,
    );
  }
}
