import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final List<User> _users = [];
  User? _current;
  bool _isSwitching = false;

  List<User> get users => List.unmodifiable(_users);
  User? get currentUser => _current;
  bool get hasUser => _users.isNotEmpty;

  static const _prefsKey = 'current_user_id';

  Future<void> load() async {
    _users.clear();
    final rows = await DatabaseHelper.instance.getAllUsersRaw();
    _users.addAll(rows.map((r) => User.fromMap(r)));

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_prefsKey);
    if (id != null) {
      try {
        _current = _users.firstWhere((u) => u.id == id);
        // Ensure DatabaseHelper is using the current user's DB
        await DatabaseHelper.instance.switchUser(_current?.id);
        // Pre-open the per-user database so subsequent reads work immediately
        await DatabaseHelper.instance.userDatabase;
      } catch (_) {
        _current = _users.isNotEmpty ? _users.first : null;
      }
    } else if (_users.isNotEmpty) {
      _current = _users.first;
      prefs.setInt(_prefsKey, _current!.id!);
      // Switch DB to the first user by default
      await DatabaseHelper.instance.switchUser(_current!.id);
      await DatabaseHelper.instance.userDatabase;
    }
    notifyListeners();
  }

  Future<User?> addUser(String name, {String? email}) async {
    final user = User(name: name, email: email);
    final id = await DatabaseHelper.instance.insertUser(user.toMap());
    final created = User(
      id: id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    );
    _users.insert(0, created);
    // Initialize per-user DB and switch to it
    await DatabaseHelper.instance.switchUser(created.id);
    // Ensure the user DB is created/opened
    await DatabaseHelper.instance.userDatabase;
    await setCurrentUser(created);
    notifyListeners();
    return created;
  }

  Future<void> deleteUser(User u) async {
    if (u.id == null) return;
    await DatabaseHelper.instance.deleteUser(u.id!);
    _users.removeWhere((e) => e.id == u.id);
    if (_current?.id == u.id) {
      _current = _users.isNotEmpty ? _users.first : null;
      final prefs = await SharedPreferences.getInstance();
      if (_current != null) {
        prefs.setInt(_prefsKey, _current!.id!);
        // Switch the per-user DB to the new current user
        await DatabaseHelper.instance.switchUser(_current!.id);
        await DatabaseHelper.instance.userDatabase;
      } else {
        prefs.remove(_prefsKey);
        // No users left; switch back to legacy single DB
        await DatabaseHelper.instance.switchUser(null);
      }
    }
    notifyListeners();
  }

  Future<void> setCurrentUser(User u) async {
    if (_isSwitching) return;
    _isSwitching = true;
    try {
      if (_current?.id == u.id) return;
      _current = u;
      // Switch per-user DB to the selected user
      await DatabaseHelper.instance.switchUser(u.id);
      // Pre-open the user DB
      await DatabaseHelper.instance.userDatabase;
      final prefs = await SharedPreferences.getInstance();
      if (u.id != null) {
        await prefs.setInt(_prefsKey, u.id!);
      }
      notifyListeners();
    } finally {
      _isSwitching = false;
    }
  }
}
