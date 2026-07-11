import 'package:dio/dio.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/data/remote/dto/order_dto.dart';
import 'package:codeacademy/domain/model/order.dart';
import 'package:codeacademy/domain/model/progress.dart';
import 'package:codeacademy/domain/model/wishlist.dart';
import 'package:codeacademy/domain/model/review.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/certificate.dart';
import 'package:codeacademy/domain/repository/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _dio.get('/enrollments/');
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => OrderDto.fromJson(item).toDomain()).toList();
      }
      throw ApiException(message: 'Error al obtener inscripciones', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _dio.get('/enrollments/');
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => OrderDto.fromJson(item).toDomain()).toList();
      }
      throw ApiException(message: 'Error al obtener inscripciones de administración', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Order> createOrder(int courseId) async {
    try {
      final response = await _dio.post(
        '/enrollments/',
        data: {'course': courseId},
      );
      if (response.statusCode == 201) {
        return OrderDto.fromJson(response.data).toDomain();
      }
      throw ApiException(message: 'Error al inscribirse en el curso', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Progress tracking
  @override
  Future<List<Progress>> getProgress({int? enrollmentId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (enrollmentId != null) {
        queryParams['enrollment'] = enrollmentId;
      }
      final response = await _dio.get('/progress/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Progress.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener progreso', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Progress> updateProgress({
    required int enrollmentId,
    required int lessonId,
    required bool completed,
  }) async {
    try {
      // Check if progress already exists for this lesson
      final getResponse = await _dio.get('/progress/', queryParameters: {
        'enrollment': enrollmentId,
        'lesson': lessonId,
      });
      
      final results = getResponse.data['results'] as List? ?? [];
      if (results.isNotEmpty) {
        // Update existing progress record
        final progressId = results.first['id'] as int;
        final patchResponse = await _dio.patch('/progress/$progressId/', data: {
          'completed': completed,
        });
        if (patchResponse.statusCode == 200) {
          return Progress.fromJson(patchResponse.data);
        }
      } else {
        // Create new progress record
        final postResponse = await _dio.post('/progress/', data: {
          'enrollment': enrollmentId,
          'lesson': lessonId,
          'completed': completed,
        });
        if (postResponse.statusCode == 201) {
          return Progress.fromJson(postResponse.data);
        }
      }
      throw ApiException(message: 'Error al guardar avance');
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Wishlist
  @override
  Future<List<Wishlist>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist/');
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Wishlist.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener wishlist', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Wishlist> addToWishlist(int courseId) async {
    try {
      final response = await _dio.post('/wishlist/', data: {'course': courseId});
      if (response.statusCode == 201) {
        return Wishlist.fromJson(response.data);
      }
      throw ApiException(message: 'Error al agregar a wishlist', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> removeFromWishlist(int id) async {
    try {
      final response = await _dio.delete('/wishlist/$id/');
      if (response.statusCode != 204) {
        throw ApiException(message: 'Error al remover de wishlist', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Reviews
  @override
  Future<List<Review>> getReviews({int? courseId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['course'] = courseId;
      }
      final response = await _dio.get('/reviews/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Review.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener reseñas', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<Review> createReview({
    required int courseId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post('/reviews/', data: {
        'course': courseId,
        'rating': rating,
        'comment': comment,
      });
      if (response.statusCode == 201) {
        return Review.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear reseña', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  // Quiz Attempts
  @override
  Future<QuizAttempt> createQuizAttempt(int quizId) async {
    try {
      final response = await _dio.post('/quiz-attempts/', data: {'quiz': quizId});
      if (response.statusCode == 201) {
        return QuizAttempt.fromJson(response.data);
      }
      throw ApiException(message: 'Error al iniciar intento de quiz', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<QuizAttempt>> getQuizAttempts({int? quizId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (quizId != null) {
        queryParams['quiz'] = quizId;
      }
      final response = await _dio.get('/quiz-attempts/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => QuizAttempt.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener intentos', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> submitQuizAnswer({
    required int attemptId,
    required int questionId,
    required int answerId,
  }) async {
    try {
      final response = await _dio.post('/quiz-answers/', data: {
        'attempt': attemptId,
        'question': questionId,
        'answer': answerId,
      });
      if (response.statusCode != 201) {
        throw ApiException(message: 'Error al registrar respuesta del quiz', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<Certificate>> getCertificates() async {
    try {
      final response = await _dio.get('/certificates/');
      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => Certificate.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener certificados', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode);
    }
  }
}
