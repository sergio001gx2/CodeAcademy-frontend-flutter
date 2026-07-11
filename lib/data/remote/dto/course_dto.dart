import 'package:codeacademy/domain/model/course.dart';

class CourseDto {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? image;
  final int category;
  final int? subcategory;
  final String categoryName;
  final int teacher;
  final String createdAt;
  final bool isPublished;
  final List<Lesson> lessons;

  CourseDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.image,
    required this.category,
    this.subcategory,
    required this.categoryName,
    required this.teacher,
    required this.createdAt,
    required this.isPublished,
    required this.lessons,
  });

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    final list = json['lessons'] as List? ?? [];
    return CourseDto(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      image: json['image'] as String?,
      category: json['category'] as int,
      subcategory: json['subcategory'] as int?,
      categoryName: json['category_name'] as String? ?? '',
      teacher: json['teacher'] as int,
      createdAt: json['created_at'] as String? ?? '',
      isPublished: json['is_published'] as bool? ?? false,
      lessons: list.map((item) => Lesson.fromJson(item)).toList(),
    );
  }

  Course toDomain() {
    return Course(
      id: id,
      title: title,
      description: description,
      price: price,
      image: image,
      category: category,
      subcategory: subcategory,
      categoryName: categoryName,
      teacher: teacher,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      isPublished: isPublished,
      lessons: lessons,
    );
  }
}
