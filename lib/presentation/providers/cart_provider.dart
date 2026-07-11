import 'package:flutter/material.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/repository/order_repository.dart';

class CartProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final List<Course> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  List<Course> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price);

  bool isInCart(Course course) {
    return _items.any((item) => item.id == course.id);
  }

  void addToCart(Course course) {
    if (!isInCart(course)) {
      _items.add(course);
      notifyListeners();
    }
  }

  void removeFromCart(Course course) {
    _items.removeWhere((item) => item.id == course.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Inscribe al estudiante en todos los cursos del carrito
      for (final course in _items) {
        await _orderRepository.createOrder(course.id);
      }
      clearCart();
      return true;
    } catch (e) {
      _errorMessage = 'Error al procesar la inscripción de los cursos';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
