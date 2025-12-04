import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import 'balance_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Expense> _items = [];
  bool _loading = false;

  List<Expense> get items => _items;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _db.getAllExpenses();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    try {
      await _db.insertExpense(e);
      await load();
    } catch (error) {
      debugPrint('Error adding expense: $error');
      rethrow;
    }
  }

  /// Add an income entry. This inserts the record and increases the stored balance.
  Future<void> addIncome(Expense e, BalanceProvider balanceProvider) async {
    try {
      await _db.insertExpense(e);
      // Increase balance by income amount
      await balanceProvider.addToBalance(e.amount);
      await load();
    } catch (error) {
      debugPrint('Error adding income: $error');
      rethrow;
    }
  }

  /// Add an expense entry and deduct from stored balance atomically.
  Future<void> addExpense(Expense e, BalanceProvider balanceProvider) async {
    try {
      // Insert the expense first
      await _db.insertExpense(e);
      // Deduct balance
      await balanceProvider.addToBalance(-e.amount);
      // If remaining balance is extremely close to zero, snap to 0
      if (balanceProvider.totalBalance.abs() < 0.0001) {
        await balanceProvider.setBalance(0);
      }
      await load();
    } catch (error) {
      debugPrint('Error adding expense (with balance update): $error');
      rethrow;
    }
  }

  Future<void> remove(int id) async {
    await _db.deleteExpense(id);
    await load();
  }

  /// Remove an expense and optionally refund its amount back to the stored balance.
  Future<void> removeWithRefund(
    Expense e,
    BalanceProvider balanceProvider, {
    bool refund = true,
  }) async {
    if (e.id == null) return;
    await _db.deleteExpense(e.id!);
    if (refund) {
      await balanceProvider.addToBalance(e.amount);
    }
    await load();
  }
}
