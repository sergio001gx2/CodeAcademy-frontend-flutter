import 'package:codeacademy/domain/model/order.dart';
import 'package:codeacademy/domain/model/progress.dart';
import 'package:codeacademy/domain/model/wishlist.dart';
import 'package:codeacademy/domain/model/review.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/certificate.dart';

abstract class OrderRepository {
  // Student Enrollment list
  Future<List<Order>> getMyOrders();
  // Admin Enrollment list
  Future<List<Order>> getAllOrders();
  // Enroll / purchase course
  Future<Order> createOrder(int courseId);

  // Progress tracking
  Future<List<Progress>> getProgress({int? enrollmentId});
  Future<Progress> updateProgress({
    required int enrollmentId,
    required int lessonId,
    required bool completed,
  });

  // Wishlist
  Future<List<Wishlist>> getWishlist();
  Future<Wishlist> addToWishlist(int courseId);
  Future<void> removeFromWishlist(int id);

  // Reviews
  Future<List<Review>> getReviews({int? courseId});
  Future<Review> createReview({
    required int courseId,
    required int rating,
    required String comment,
  });

  // Quiz Attempts
  Future<QuizAttempt> createQuizAttempt(int quizId);
  Future<List<QuizAttempt>> getQuizAttempts({int? quizId});
  Future<void> submitQuizAnswer({
    required int attemptId,
    required int questionId,
    required int answerId,
  });

  // Certificates
  Future<List<Certificate>> getCertificates();
}
