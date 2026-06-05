import '../database/database_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper;

  ProductRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<ProductModel>> fetchProducts() async {
    final db = await _dbHelper.database;
    final rows = await db.query(DatabaseHelper.tableProducts, orderBy: 'name');
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.tableProducts, product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Редактирование карточки товара администратором: обновляет название,
  /// описание, картинку и статус. При смене статуса на «свободен»
  /// очищает данные об аренде.
  Future<void> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    final isFree = product.status == ProductStatus.free;
    await db.update(
      DatabaseHelper.tableProducts,
      {
        'name': product.name,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'imageBytes': product.imageBytes,
        'status': product.status.name,
        if (isFree) 'rentedBy': null,
        if (isFree) 'rentedAt': null,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Пользователь берёт товар: статус → occupied, фиксируем кто и когда,
  /// записываем строку в историю аренды.
  Future<void> rentProduct({
    required String productId,
    required String userEmail,
  }) async {
    final db = await _dbHelper.database;
    final takenAt = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.update(
        DatabaseHelper.tableProducts,
        {
          'status': ProductStatus.occupied.name,
          'rentedBy': userEmail,
          'rentedAt': takenAt,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
      await txn.insert(DatabaseHelper.tableRentals, {
        'productId': productId,
        'userEmail': userEmail,
        'takenAt': takenAt,
      });
    });
  }

  /// Возврат товара: статус → free, очищаем аренду,
  /// закрываем последнюю открытую запись в истории.
  Future<void> returnProduct(String productId) async {
    final db = await _dbHelper.database;
    final returnedAt = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.update(
        DatabaseHelper.tableProducts,
        {
          'status': ProductStatus.free.name,
          'rentedBy': null,
          'rentedAt': null,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
      // Закрываем последнюю незавершённую аренду
      final open = await txn.query(
        DatabaseHelper.tableRentals,
        where: 'productId = ? AND returnedAt IS NULL',
        whereArgs: [productId],
        orderBy: 'takenAt DESC',
        limit: 1,
      );
      if (open.isNotEmpty) {
        await txn.update(
          DatabaseHelper.tableRentals,
          {'returnedAt': returnedAt},
          where: 'id = ?',
          whereArgs: [open.first['id']],
        );
      }
    });
  }

  /// Ручная смена статуса администратором (без записи в историю аренды).
  Future<void> setStatus(String productId, ProductStatus status) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableProducts,
      {
        'status': status.name,
        'rentedBy': null,
        'rentedAt': null,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<ProductModel?> findById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }
}
