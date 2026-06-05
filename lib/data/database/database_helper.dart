import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Синглтон для доступа к локальной БД SQLite.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'micro_zone.db';
  static const _dbVersion = 2;

  static const tableUsers = 'users';
  static const tableProducts = 'products';
  static const tableRentals = 'rentals';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2: храним картинку товара прямо в БД (выбор из галереи).
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableProducts ADD COLUMN imageBytes BLOB');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        email     TEXT PRIMARY KEY,
        name      TEXT NOT NULL,
        password  TEXT NOT NULL,
        role      TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProducts (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl    TEXT NOT NULL DEFAULT '',
        imageBytes  BLOB,
        status      TEXT NOT NULL DEFAULT 'free',
        rentedBy    TEXT,
        rentedAt    INTEGER
      )
    ''');

    // История аренды: кто и когда взял/вернул товар.
    await db.execute('''
      CREATE TABLE $tableRentals (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        productId   TEXT NOT NULL,
        userEmail   TEXT NOT NULL,
        takenAt     INTEGER NOT NULL,
        returnedAt  INTEGER,
        FOREIGN KEY (productId) REFERENCES $tableProducts(id) ON DELETE CASCADE,
        FOREIGN KEY (userEmail) REFERENCES $tableUsers(email) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  /// Первичное наполнение БД при создании.
  Future<void> _seedData(Database db) async {
    final batch = db.batch();

    // Встроенный администратор
    batch.insert(tableUsers, {
      'email': 'admin',
      'name': 'Администратор',
      'password': 'admin',
      'role': 'admin',
    });

    const seedProducts = [
      ['1', 'Ноутбук Dell XPS 15',
        'Мощный ноутбук для профессионалов с экраном OLED 15.6" и процессором Intel Core i9.',
        'https://picsum.photos/seed/laptop/400/300', 'free'],
      ['2', 'iPhone 15 Pro',
        'Флагманский смартфон Apple с чипом A17 Pro и камерой 48 Мп.',
        'https://picsum.photos/seed/phone/400/300', 'occupied'],
      ['3', 'Sony WH-1000XM5',
        'Беспроводные наушники с лучшим в классе шумоподавлением и автономностью 30 часов.',
        'https://picsum.photos/seed/headphones/400/300', 'free'],
      ['4', 'iPad Pro 12.9"',
        'Планшет с чипом M2 и дисплеем Liquid Retina XDR для творческих задач.',
        'https://picsum.photos/seed/tablet/400/300', 'free'],
      ['5', 'Canon EOS R5',
        'Профессиональная беззеркальная камера с разрешением 45 Мп и видео 8K RAW.',
        'https://picsum.photos/seed/camera/400/300', 'occupied'],
      ['6', 'Samsung Galaxy Watch 6',
        'Смарт-часы с мониторингом здоровья, GPS и защитой от воды 5 ATM.',
        'https://picsum.photos/seed/smartwatch/400/300', 'free'],
    ];

    for (final pr in seedProducts) {
      batch.insert(tableProducts, {
        'id': pr[0],
        'name': pr[1],
        'description': pr[2],
        'imageUrl': pr[3],
        'status': pr[4],
      });
    }

    await batch.commit(noResult: true);
  }
}
