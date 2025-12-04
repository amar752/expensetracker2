import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../providers/balance_provider.dart';
import '../models/expense.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101225),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'All Expenses',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          final expenses = _filterExpenses(provider.items);

          return RefreshIndicator(
            onRefresh: () async {
              await provider.load();
            },
            color: const Color(0xFF6C5CE7),
            backgroundColor: const Color(0xFF161936),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: expenses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return _buildExpenseItem(expense, provider)
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideX(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOut,
                                );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    var filtered = expenses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.category.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((e) => e.category == _selectedFilter).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161936),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white38),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [
      'All',
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Bills',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedFilter == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = selected ? category : 'All');
              },
              selectedColor: const Color(0xFF6C5CE7),
              backgroundColor: const Color(0xFF161936),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.white30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense, ExpenseProvider provider) {
    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (direction) async {
        final balanceProvider = context.read<BalanceProvider>();
        // Delete and refund the amount to the stored balance
        await provider.removeWithRefund(expense, balanceProvider, refund: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.title} deleted'),
            backgroundColor: const Color(0xFF161936),
            action: SnackBarAction(
              label: 'Undo',
              textColor: const Color(0xFF6C5CE7),
              onPressed: () async {
                // Re-insert the expense and deduct the amount (reverse refund)
                await provider.addExpense(expense, balanceProvider);
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // Optional: Navigate to expense details
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF161936),
                const Color(0xFF161936).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor(expense.category).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: _getCategoryColor(expense.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(expense.amount)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.paymentMethod,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No expenses found' : 'No expenses yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': const Color(0xFFFF6B6B),
      'Transport': const Color(0xFF4ECDC4),
      'Shopping': const Color(0xFF95E77E),
      'Entertainment': const Color(0xFFFFD93D),
      'Bills': const Color(0xFF6C5CE7),
      'Healthcare': const Color(0xFFA8E6CF),
      'Education': const Color(0xFFFFAEC9),
      'Uncategorized': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt_long,
      'Healthcare': Icons.medical_services,
      'Education': Icons.school,
      'Uncategorized': Icons.category_outlined,
    };
    return icons[category] ?? Icons.category;
  }
}
