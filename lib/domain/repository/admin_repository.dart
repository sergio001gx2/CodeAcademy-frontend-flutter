import 'package:codeacademy/domain/model/user.dart';

abstract class AdminRepository {
  Future<List<User>> getUsers({String? search});
  Future<User> createUser(Map<String, dynamic> userData);
  Future<User> updateUser(int id, Map<String, dynamic> userData);
  Future<void> deleteUser(int id);
}
