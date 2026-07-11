import 'package:codeacademy/domain/model/category.dart';

class CategoryDto {
  final int id;
  final String name;
  final String slug;

  CategoryDto({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      slug: slug,
    );
  }
}
