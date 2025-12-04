import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _metaDb;

  Database? _userDb;
  int? _currentUserId;

  Future<Database> get metaDatabase async =>
      _metaDb ??= await _initMetaDB('expense_tracker_meta.db');

  Future<Database> get userDatabase async {
    if (_userDb != null) return _userDb!;
    final name = _currentUserId == null
        ? 'expense_tracker.db'
        : 'expense_tracker_user_${_currentUserId!}.db';
    _userDb = await _initUserDB(name);
    return _userDb!;
  }

  Future<Database> _initMetaDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    debugPrint('Meta DB path: $path');
    return openDatabase(path, version: 1, onCreate: _createMetaDB);
  }

  Future<Database> _initUserDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    debugPrint('User DB path: $path');
    return openDatabase(path, version: 1, onCreate: _createUserDB);
  }

  Future<void> _createMetaDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createUserDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        paymentMethod TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        isIncome INTEGER NOT NULL,
        budgetLimit REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        period TEXT NOT NULL
      )
    ''');

    for (final c in Category.defaultCategories) {
      await db.insert('categories', c.toMap());
    }
  }

  Future<void> switchUser(int? userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    if (_userDb != null) {
      try {
        await _userDb!.close();
      } catch (_) {}
      _userDb = null;
    }
  }

  // ------------------ Meta DB (users) ------------------
  Future<int> insertUser(Map<String, Object?> values) async {
    final db = await metaDatabase;
    return db.insert('users', values);
  }

  Future<List<Map<String, Object?>>> getAllUsersRaw() async {
    final db = await metaDatabase;
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<int> deleteUser(int id) async {
    final db = await metaDatabase;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------ Per-user DB (expenses/categories/budgets) ------------------
  Future<int> insertExpense(Expense e) async {
    final db = await userDatabase;
    try {
      return await db.insert('expenses', e.toMap());
    } catch (err, st) {
      final values = e.toMap();
      debugPrint(
        'Failed to insert into expenses. values: ${values.map((k, v) => MapEntry(k, v.runtimeType))}',
      );
      debugPrint('Error: $err');
      debugPrint('Stack: $st');
      rethrow;
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await userDatabase;
    final res = await db.query('expenses', orderBy: 'date DESC');
    return res.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> updateExpense(Expense e) async {
    final db = await userDatabase;
    return db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await userDatabase;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await userDatabase;
    final res = await db.query('categories');
    return res.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> upsertBudget(Budget b) async {
    final db = await userDatabase;
    if (b.id == null) return db.insert('budgets', b.toMap());
    return db.update('budgets', b.toMap(), where: 'id = ?', whereArgs: [b.id]);
  }
}
