import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/model/category.dart';
import 'package:codeacademy/domain/model/subcategory.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/forum.dart';
import 'package:codeacademy/domain/repository/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _catalogRepository;

  List<Course> _courses = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  Course? _selectedCourse;
  
  List<DiscussionForum> _forums = [];
  List<ForumPost> _posts = [];
  List<ForumComment> _comments = [];
  List<Quiz> _quizzes = [];
  List<Question> _questions = [];

  bool _isLoading = false;
  String? _errorMessage;

  CatalogProvider({required CatalogRepository catalogRepository})
      : _catalogRepository = catalogRepository {
    loadCategories();
    loadCourses();
  }

  List<Course> get courses => _courses;
  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;
  Course? get selectedCourse => _selectedCourse;
  
  List<DiscussionForum> get forums => _forums;
  List<ForumPost> get posts => _posts;
  List<ForumComment> get comments => _comments;
  List<Quiz> get quizzes => _quizzes;
  List<Question> get questions => _questions;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    try {
      _categories = await _catalogRepository.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCourses({String? search, int? categoryId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _catalogRepository.getCourses(search: search, categoryId: categoryId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar los cursos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubcategories({int? categoryId}) async {
    try {
      _subcategories = await _catalogRepository.getSubcategories(categoryId: categoryId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadCourseById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCourse = null;
    notifyListeners();

    try {
      _selectedCourse = await _catalogRepository.getCourseById(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar el detalle del curso';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forum logic
  Future<void> loadForums(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _forums = [];
    notifyListeners();
    try {
      _forums = await _catalogRepository.getForums(courseId: courseId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar foros';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createForum(int courseId, String title, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final forum = await _catalogRepository.createForum(courseId, title, description);
      _forums.insert(0, forum);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear foro';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForumPosts(int forumId) async {
    _isLoading = true;
    _errorMessage = null;
    _posts = [];
    notifyListeners();
    try {
      _posts = await _catalogRepository.getForumPosts(forumId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar publicaciones';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createForumPost(int forumId, String title, String content) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final post = await _catalogRepository.createForumPost(forumId, title, content);
      _posts.insert(0, post);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear publicación';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForumComments(int postId) async {
    _isLoading = true;
    _errorMessage = null;
    _comments = [];
    notifyListeners();
    try {
      _comments = await _catalogRepository.getForumComments(postId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar comentarios';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createForumComment(int postId, String content) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final comment = await _catalogRepository.createForumComment(postId, content);
      _comments.add(comment);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al comentar';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Quiz logic
  Future<void> loadQuizzes(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _quizzes = [];
    notifyListeners();
    try {
      _quizzes = await _catalogRepository.getQuizzes(courseId: courseId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar cuestionarios';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuestions(int quizId) async {
    _isLoading = true;
    _errorMessage = null;
    _questions = [];
    notifyListeners();
    try {
      _questions = await _catalogRepository.getQuestions(quizId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar preguntas del cuestionario';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createQuizFull({
    required int courseId,
    required String title,
    required String description,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final quiz = await _catalogRepository.createQuiz({
        'course': courseId,
        'title': title,
        'description': description,
        'is_published': true,
      });

      final question = await _catalogRepository.createQuestion({
        'quiz': quiz.id,
        'text': questionText,
        'order': 1,
      });

      await _catalogRepository.createAnswer({
        'question': question.id,
        'text': optionA,
        'is_correct': true,
      });
      await _catalogRepository.createAnswer({
        'question': question.id,
        'text': optionB,
        'is_correct': false,
      });
      await _catalogRepository.createAnswer({
        'question': question.id,
        'text': optionC,
        'is_correct': false,
      });

      _quizzes = await _catalogRepository.getQuizzes(courseId: courseId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al crear el examen';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
