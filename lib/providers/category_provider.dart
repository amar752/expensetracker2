import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> load() async {
    _categories = await _db.getAllCategories();
    notifyListeners();
  }
}
