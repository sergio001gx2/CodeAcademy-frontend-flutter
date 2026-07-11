import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/model/category.dart';
import 'package:codeacademy/domain/model/subcategory.dart';
import 'package:codeacademy/domain/repository/catalog_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final CatalogRepository _catalogRepository;

  List<Course> _myCourses = [];
  List<Lesson> _lessons = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];

  bool _isLoading = false;
  String? _errorMessage;

  TeacherProvider({required CatalogRepository catalogRepository})
      : _catalogRepository = catalogRepository;

  List<Course> get myCourses => _myCourses;
  List<Lesson> get lessons => _lessons;
  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load teacher's own courses
  Future<void> loadMyCourses(int teacherId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myCourses = await _catalogRepository.getCourses(teacherId: teacherId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar tus cursos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories for course form
  Future<void> loadCategories() async {
    try {
      _categories = await _catalogRepository.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  // Load subcategories, optionally filtered by category
  Future<void> loadSubcategories({int? categoryId}) async {
    try {
      _subcategories = await _catalogRepository.getSubcategories(categoryId: categoryId);
      notifyListeners();
    } catch (_) {
      _subcategories = [];
      notifyListeners();
    }
  }

  // Create a course (teacher creates with themselves as teacher)
  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.createCourse(courseData);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear el curso';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update course
  Future<bool> updateCourse(int id, Map<String, dynamic> courseData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.updateCourse(id, courseData);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al actualizar el curso';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete course
  Future<bool> deleteCourse(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.deleteCourse(id);
      _myCourses.removeWhere((c) => c.id == id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al eliminar el curso';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load lessons for a specific course
  Future<void> loadLessons(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _lessons = [];
    notifyListeners();
    try {
      _lessons = await _catalogRepository.getLessons(courseId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar lecciones';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create lesson
  Future<bool> createLesson(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final lesson = await _catalogRepository.createLesson(data);
      _lessons.add(lesson);
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear la lección';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update lesson
  Future<bool> updateLesson(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _catalogRepository.updateLesson(id, data);
      final index = _lessons.indexWhere((l) => l.id == id);
      if (index != -1) _lessons[index] = updated;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al actualizar la lección';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete lesson
  Future<bool> deleteLesson(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.deleteLesson(id);
      _lessons.removeWhere((l) => l.id == id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al eliminar la lección';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
