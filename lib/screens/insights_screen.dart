import 'package:expensetracker2/models/category.dart';
import 'package:expensetracker2/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ExpenseProvider>().load();
      context.read<CategoryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101225),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Insights', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer2<ExpenseProvider, CategoryProvider>(
        builder: (context, expenseProvider, categoryProvider, _) {
          final expenses = _filterExpensesByPeriod(expenseProvider.items);
          final categoryTotals = _calculateCategoryTotals(expenses);
          final total = categoryTotals.values.fold<double>(
            0,
            (sum, val) => sum + val,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                _buildTotalCard(total),
                const SizedBox(height: 24),
                if (categoryTotals.isNotEmpty) ...[
                  _buildPieChart(categoryTotals, categoryProvider),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(
                    categoryTotals,
                    total,
                    categoryProvider,
                  ),
                ] else
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Expense> _filterExpensesByPeriod(List<Expense> expenses) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return expenses
        .where(
          (e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))),
        )
        .toList();
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Widget _buildPeriodSelector() {
    final periods = ['Today', 'This Week', 'This Month', 'This Year'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = _selectedPeriod == period;

          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFF161936),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A59), Color(0xFFFF9472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Spent',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                    .format(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.trending_up, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> categoryTotals,
    CategoryProvider categoryProvider,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(20),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: categoryTotals.entries.map((entry) {
            final category = categoryProvider.categories.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => Category.defaultCategories.first,
            );

            return PieChartSectionData(
              color: category.color,
              value: entry.value,
              title:
                  '${(entry.value / categoryTotals.values.fold(0, (a, b) => a + b) * 100).toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<String, double> categoryTotals,
    double total,
    CategoryProvider categoryProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...categoryTotals.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total * 100) : 0;
          final category = categoryProvider.categories.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => Category.defaultCategories.first,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161936),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                          .format(entry.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  minHeight: 4,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.pie_chart_outline,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data for $_selectedPeriod',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
