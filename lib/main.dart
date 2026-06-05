import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализируем БД (создаёт таблицы и наполняет их при первом запуске).
  await DatabaseHelper.instance.database;
  runApp(const MicroZoneApp());
}