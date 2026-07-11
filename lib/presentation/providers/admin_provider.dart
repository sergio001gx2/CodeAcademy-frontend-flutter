import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/model/category.dart';
import 'package:codeacademy/domain/model/user.dart';
import 'package:codeacademy/domain/model/order.dart';
import 'package:codeacademy/domain/repository/catalog_repository.dart';
import 'package:codeacademy/domain/repository/admin_repository.dart';
import 'package:codeacademy/domain/repository/order_repository.dart';

class AdminProvider extends ChangeNotifier {
  final CatalogRepository _catalogRepository;
  final AdminRepository _adminRepository;
  final OrderRepository _orderRepository;

  List<Course> _courses = [];
  List<Category> _categories = [];
  List<User> _users = [];
  List<Order> _enrollments = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  AdminProvider({
    required CatalogRepository catalogRepository,
    required AdminRepository adminRepository,
    required OrderRepository orderRepository,
  })  : _catalogRepository = catalogRepository,
        _adminRepository = adminRepository,
        _orderRepository = orderRepository;

  List<Course> get courses => _courses;
  List<Category> get categories => _categories;
  List<User> get users => _users;
  List<Order> get enrollments => _enrollments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // course CRUD
  Future<void> loadCourses({int? teacherId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _courses = await _catalogRepository.getCourses(teacherId: teacherId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar cursos en administración';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.createCourse(courseData);
      await loadCourses();
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

  Future<bool> updateCourse(int id, Map<String, dynamic> courseData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.updateCourse(id, courseData);
      await loadCourses();
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

  Future<bool> deleteCourse(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.deleteCourse(id);
      _courses.removeWhere((c) => c.id == id);
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

  // category CRUD
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _catalogRepository.getCategories();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar categorías';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name, String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.createCategory(name, slug);
      await loadCategories();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear la categoría';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(int id, String name, String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.updateCategory(id, name, slug);
      await loadCategories();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al actualizar la categoría';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _catalogRepository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al eliminar la categoría';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // user CRUD
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await _adminRepository.getUsers();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar usuarios en administración';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _adminRepository.createUser(userData);
      await loadUsers();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al crear el usuario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _adminRepository.updateUser(id, userData);
      await loadUsers();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al actualizar el usuario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _adminRepository.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Error al eliminar el usuario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auditing Enrollments (Admin Orders)
  Future<void> loadAllEnrollments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _enrollments = await _orderRepository.getAllOrders();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar todas las matrículas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
