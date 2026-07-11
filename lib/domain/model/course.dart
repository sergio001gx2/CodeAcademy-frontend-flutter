class Lesson {
  final int id;
  final String title;
  final String content;
  final String? videoUrl;
  final int order;
  final int duration;
  final int course;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.order,
    required this.duration,
    required this.course,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      videoUrl: json['video_url'] as String?,
      order: json['order'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      course: json['course'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'video_url': videoUrl,
      'order': order,
      'duration': duration,
      'course': course,
    };
  }
}

class Course {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? image;
  final int category;
  final int? subcategory;
  final String categoryName;
  final int teacher;
  final DateTime createdAt;
  final bool isPublished;
  final List<Lesson> lessons;

  Course({
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

  factory Course.fromJson(Map<String, dynamic> json) {
    final list = json['lessons'] as List? ?? [];
    return Course(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      image: json['image'] as String?,
      category: json['category'] as int,
      subcategory: json['subcategory'] as int?,
      categoryName: json['category_name'] as String? ?? '',
      teacher: json['teacher'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isPublished: json['is_published'] as bool? ?? false,
      lessons: list.map((item) => Lesson.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price.toStringAsFixed(2),
      'image': image,
      'category': category,
      'subcategory': subcategory,
      'category_name': categoryName,
      'teacher': teacher,
      'created_at': createdAt.toIso8601String(),
      'is_published': isPublished,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}
