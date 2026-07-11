import 'package:dio/dio.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/data/remote/dto/course_dto.dart';
import 'package:codeacademy/data/remote/dto/category_dto.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/model/category.dart';
import 'package:codeacademy/domain/model/subcategory.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/forum.dart';
import 'package:codeacademy/domain/repository/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final Dio _dio;

  CatalogRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Course>> getCourses({String? search, int? categoryId, int? teacherId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }
      if (teacherId != null) {
        queryParams['teacher'] = teacherId;
      }

      final response = await _dio.get(
        AppConfig.coursesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => CourseDto.fromJson(item).toDomain()).toList();
      }
      throw ApiException(message: 'Error al obtener cursos', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Course> getCourseById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.coursesEndpoint}$id/');
      if (response.statusCode == 200) {
        return CourseDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Curso no encontrado', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Course> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.post(
        AppConfig.coursesEndpoint,
        data: courseData,
      );
      if (response.statusCode == 201) {
        return CourseDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Error al crear curso', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Course> updateCourse(int id, Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.put(
        '${AppConfig.coursesEndpoint}$id/',
        data: courseData,
      );
      if (response.statusCode == 200) {
        return CourseDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Error al actualizar curso', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      final response = await _dio.delete('${AppConfig.coursesEndpoint}$id/');
      if (response.statusCode != 204) {
        throw ApiException(message: 'Error al eliminar curso', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Category>> getCategories({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        AppConfig.categoriesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => CategoryDto.fromJson(item).toDomain()).toList();
      }
      throw ApiException(message: 'Error al obtener categorías', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.categoriesEndpoint}$id/');
      if (response.statusCode == 200) {
        return CategoryDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Categoría no encontrada', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Category> createCategory(String name, String slug) async {
    try {
      final response = await _dio.post(
        AppConfig.categoriesEndpoint,
        data: {
          'name': name,
          'slug': slug,
        },
      );
      if (response.statusCode == 201) {
        return CategoryDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Error al crear categoría', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Category> updateCategory(int id, String name, String slug) async {
    try {
      final response = await _dio.put(
        '${AppConfig.categoriesEndpoint}$id/',
        data: {
          'name': name,
          'slug': slug,
        },
      );
      if (response.statusCode == 200) {
        return CategoryDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Error al actualizar categoría', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      final response = await _dio.delete('${AppConfig.categoriesEndpoint}$id/');
      if (response.statusCode != 204) {
        throw ApiException(message: 'Error al eliminar categoría', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Forum Implementation
  @override
  Future<List<DiscussionForum>> getForums({int? courseId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['course'] = courseId;
      }
      final response = await _dio.get('/discussion-forums/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => DiscussionForum.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener foros', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<DiscussionForum> createForum(int courseId, String title, String description) async {
    try {
      final response = await _dio.post(
        '/discussion-forums/',
        data: {
          'course': courseId,
          'title': title,
          'description': description,
        },
      );
      if (response.statusCode == 201) {
        return DiscussionForum.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear foro', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<ForumPost>> getForumPosts(int forumId) async {
    try {
      final response = await _dio.get('/forum-posts/', queryParameters: {'forum': forumId});
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => ForumPost.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener posts del foro', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<ForumPost> createForumPost(int forumId, String title, String content) async {
    try {
      final response = await _dio.post(
        '/forum-posts/',
        data: {
          'forum': forumId,
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == 201) {
        return ForumPost.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear post', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<ForumComment>> getForumComments(int postId) async {
    try {
      final response = await _dio.get('/forum-comments/', queryParameters: {'post': postId});
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => ForumComment.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener comentarios del post', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<ForumComment> createForumComment(int postId, String content) async {
    try {
      final response = await _dio.post(
        '/forum-comments/',
        data: {
          'post': postId,
          'content': content,
        },
      );
      if (response.statusCode == 201) {
        return ForumComment.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear comentario', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Quiz Implementation
  @override
  Future<List<Quiz>> getQuizzes({int? courseId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['course'] = courseId;
      }
      final response = await _dio.get('/quizzes/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Quiz.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener quizzes', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<Question>> getQuestions(int quizId) async {
    try {
      final response = await _dio.get('/questions/', queryParameters: {'quiz': quizId});
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Question.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener preguntas', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Quiz> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/quizzes/', data: data);
      if (response.statusCode == 201) {
        return Quiz.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear cuestionario', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Question> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/questions/', data: data);
      if (response.statusCode == 201) {
        return Question.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear pregunta', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Answer> createAnswer(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/answers/', data: data);
      if (response.statusCode == 201) {
        return Answer.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear respuesta', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Subcategory
  @override
  Future<List<Subcategory>> getSubcategories({int? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category'] = categoryId;
      final response = await _dio.get('/subcategories/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Subcategory.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener subcategorías', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Subcategory> createSubcategory(String name, String slug, int categoryId) async {
    try {
      final response = await _dio.post('/subcategories/', data: {
        'name': name,
        'slug': slug,
        'category': categoryId,
      });
      if (response.statusCode == 201) {
        return Subcategory.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear subcategoría', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Lesson CRUD
  @override
  Future<List<Lesson>> getLessons(int courseId) async {
    try {
      final response = await _dio.get('/lessons/', queryParameters: {'course': courseId});
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Lesson.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener lecciones', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Lesson> createLesson(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/lessons/', data: data);
      if (response.statusCode == 201) {
        return Lesson.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear lección', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Lesson> updateLesson(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/lessons/$id/', data: data);
      if (response.statusCode == 200) {
        return Lesson.fromJson(response.data);
      }
      throw ApiException(message: 'Error al actualizar lección', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> deleteLesson(int id) async {
    try {
      final response = await _dio.delete('/lessons/$id/');
      if (response.statusCode != 204) {
        throw ApiException(message: 'Error al eliminar lección', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Course Tags
  @override
  Future<List<String>> getCourseTags(int courseId) async {
    try {
      final response = await _dio.get('/course-tags/', queryParameters: {'course': courseId});
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => item['tag_name']?.toString() ?? item['tag']?.toString() ?? '').toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<void> addCourseTag(int courseId, String tag) async {
    try {
      await _dio.post('/course-tags/', data: {'course': courseId, 'tag': tag});
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }
}
