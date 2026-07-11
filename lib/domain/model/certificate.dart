class Certificate {
  final int id;
  final int student;
  final int course;
  final String courseTitle;
  final String studentName;
  final DateTime issuedAt;
  final String certificateCode;

  Certificate({
    required this.id,
    required this.student,
    required this.course,
    required this.courseTitle,
    required this.studentName,
    required this.issuedAt,
    required this.certificateCode,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int,
      student: json['student'] as int,
      course: json['course'] as int,
      courseTitle: json['course_title'] as String? ?? json['course'].toString(),
      studentName: json['student_name'] as String? ?? '',
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'])
          : DateTime.now(),
      certificateCode: json['certificate_code'] as String? ?? '',
    );
  }
}
