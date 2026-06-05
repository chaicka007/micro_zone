import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DatabaseHelper.tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<bool> register(UserModel user) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      DatabaseHelper.tableUsers,
      where: 'email = ?',
      whereArgs: [user.email],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;

    await db.insert(DatabaseHelper.tableUsers, user.toMap());
    return true;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final rows = await db.query(DatabaseHelper.tableUsers, orderBy: 'name');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<void> updateUserRole(String email, UserRole role) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableUsers,
      {'role': role.name},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> deleteUser(String email) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Освобождаем товары, которые числятся за этим пользователем.
      await txn.update(
        DatabaseHelper.tableProducts,
        {'status': 'free', 'rentedBy': null, 'rentedAt': null},
        where: 'rentedBy = ?',
        whereArgs: [email],
      );
      // Удаляем самого пользователя (история аренды удалится каскадно).
      await txn.delete(
        DatabaseHelper.tableUsers,
        where: 'email = ?',
        whereArgs: [email],
      );
    });
  }
}
