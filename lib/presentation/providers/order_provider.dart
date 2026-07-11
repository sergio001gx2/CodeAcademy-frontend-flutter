import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/order.dart';
import 'package:codeacademy/domain/model/progress.dart';
import 'package:codeacademy/domain/model/wishlist.dart';
import 'package:codeacademy/domain/model/review.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/certificate.dart';
import 'package:codeacademy/domain/repository/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  
  List<Order> _orders = [];
  List<Wishlist> _wishlist = [];
  List<Review> _reviews = [];
  List<Progress> _progressList = [];
  List<QuizAttempt> _quizAttempts = [];
  QuizAttempt? _activeAttempt;
  List<Certificate> _certificates = [];

  bool _isLoading = false;
  String? _errorMessage;

  OrderProvider({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  List<Order> get orders => _orders;
  List<Wishlist> get wishlist => _wishlist;
  List<Review> get reviews => _reviews;
  List<Progress> get progressList => _progressList;
  List<QuizAttempt> get quizAttempts => _quizAttempts;
  QuizAttempt? get activeAttempt => _activeAttempt;
  List<Certificate> get certificates => _certificates;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _orderRepository.getMyOrders();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar inscripciones';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isEnrolled(int courseId) {
    return _orders.any((order) => order.course == courseId);
  }

  int? getEnrollmentIdForCourse(int courseId) {
    try {
      return _orders.firstWhere((order) => order.course == courseId).id;
    } catch (_) {
      return null;
    }
  }

  // Wishlist
  Future<void> loadWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _wishlist = await _orderRepository.getWishlist();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar lista de deseos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInWishlist(int courseId) {
    return _wishlist.any((w) => w.course == courseId);
  }

  Future<bool> addToWishlist(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final item = await _orderRepository.addToWishlist(courseId);
      _wishlist.add(item);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al agregar a lista de deseos';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromWishlist(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final item = _wishlist.firstWhere((w) => w.course == courseId);
      await _orderRepository.removeFromWishlist(item.id);
      _wishlist.removeWhere((w) => w.id == item.id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al remover de la lista de deseos';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reviews
  Future<void> loadReviews(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _reviews = [];
    notifyListeners();
    try {
      _reviews = await _orderRepository.getReviews(courseId: courseId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar reseñas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int courseId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final review = await _orderRepository.createReview(
        courseId: courseId,
        rating: rating,
        comment: comment,
      );
      _reviews.insert(0, review);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al publicar reseña';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Progress
  Future<void> loadProgress(int enrollmentId) async {
    _isLoading = true;
    _errorMessage = null;
    _progressList = [];
    notifyListeners();
    try {
      _progressList = await _orderRepository.getProgress(enrollmentId: enrollmentId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar avance';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isLessonCompleted(int lessonId) {
    return _progressList.any((p) => p.lesson == lessonId && p.completed);
  }

  Future<void> toggleLessonProgress({
    required int enrollmentId,
    required int lessonId,
    required bool completed,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _orderRepository.updateProgress(
        enrollmentId: enrollmentId,
        lessonId: lessonId,
        completed: completed,
      );
      
      _progressList.removeWhere((p) => p.lesson == lessonId);
      _progressList.add(updated);
    } catch (_) {
      _errorMessage = 'Error al actualizar el progreso';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Quiz Attempts
  Future<void> loadQuizAttempts(int quizId) async {
    _isLoading = true;
    _errorMessage = null;
    _quizAttempts = [];
    notifyListeners();
    try {
      _quizAttempts = await _orderRepository.getQuizAttempts(quizId: quizId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar intentos del cuestionario';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startQuizAttempt(int quizId) async {
    _isLoading = true;
    _errorMessage = null;
    _activeAttempt = null;
    notifyListeners();
    try {
      _activeAttempt = await _orderRepository.createQuizAttempt(quizId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al iniciar cuestionario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuizAnswers(int attemptId, Map<int, int> selectedAnswers) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      for (final entry in selectedAnswers.entries) {
        final questionId = entry.key;
        final answerId = entry.value;
        await _orderRepository.submitQuizAnswer(
          attemptId: attemptId,
          questionId: questionId,
          answerId: answerId,
        );
      }
      _activeAttempt = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al enviar las respuestas';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCertificates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _certificates = await _orderRepository.getCertificates();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar certificados';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
