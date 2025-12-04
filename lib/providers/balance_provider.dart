import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceProvider extends ChangeNotifier {
  static const String _balanceKey = 'total_balance';
  double _totalBalance = 0.0;

  double get totalBalance => _totalBalance;
  bool get hasBalance => _totalBalance > 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _totalBalance = prefs.getDouble(_balanceKey) ?? 0.0;
    notifyListeners();
  }

  Future<void> setBalance(double balance) async {
    _totalBalance = balance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
    notifyListeners();
  }

  Future<void> addToBalance(double amount) async {
    _totalBalance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _totalBalance);
    notifyListeners();
  }

  // The balance is already updated when income/expenses are added
  // So we just return the current balance, not recalculate it
  double calculateRemainingBalance(double totalExpenses, double totalIncome) {
    return _totalBalance;
  }
}
