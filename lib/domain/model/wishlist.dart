class Wishlist {
  final int id;
  final int student;
  final int course;
  final String courseTitle;
  final DateTime addedAt;

  Wishlist({
    required this.id,
    required this.student,
    required this.course,
    required this.courseTitle,
    required this.addedAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'] as int,
      student: json['student'] as int? ?? 0,
      course: json['course'] as int,
      courseTitle: json['course_title'] as String? ?? '',
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : DateTime.now(),
    );
  }
}
