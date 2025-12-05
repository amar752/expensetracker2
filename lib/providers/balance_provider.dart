import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceProvider extends ChangeNotifier {
  static const String _balanceKey = 'total_balance';
  static const String _balanceSetKey = 'initial_balance_set';
  double _totalBalance = 0.0;
  bool _isInitialBalanceSet = false;

  double get totalBalance => _totalBalance;
  bool get hasBalance => _totalBalance > 0;
  bool get isInitialBalanceSet => _isInitialBalanceSet;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _totalBalance = prefs.getDouble(_balanceKey) ?? 0.0;
    _isInitialBalanceSet = prefs.getBool(_balanceSetKey) ?? false;
    notifyListeners();
  }

  Future<void> setBalance(double balance) async {
    _totalBalance = balance;
    _isInitialBalanceSet = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
    await prefs.setBool(_balanceSetKey, true);
    notifyListeners();
  }

  Future<void> addToBalance(double amount) async {
    _totalBalance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _totalBalance);
    notifyListeners();
  }

  Future<void> clearBalance() async {
    _totalBalance = 0.0;
    _isInitialBalanceSet = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_balanceKey);
    await prefs.remove(_balanceSetKey);
    notifyListeners();
  }

  // The balance is already updated when income/expenses are added
  // So we just return the current balance, not recalculate it
  double calculateRemainingBalance(double totalExpenses, double totalIncome) {
    return _totalBalance;
  }
}
