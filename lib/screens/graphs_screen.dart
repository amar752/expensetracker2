import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String _period = '12 Months';

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
        title: const Text('Graphs', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer2<ExpenseProvider, CategoryProvider>(
        builder: (context, expenseProvider, categoryProvider, _) {
          final items = expenseProvider.items;
          final monthly = _calculateMonthlyTotals(items);
          final categoryTotals = _calculateCategoryTotals(items);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 20),
                _buildLineChart(monthly),
                const SizedBox(height: 24),
                _buildBarChart(categoryTotals, categoryProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final options = ['3 Months', '6 Months', '12 Months'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, i) {
          final o = options[i];
          final sel = o == _period;
          return GestureDetector(
            onTap: () => setState(() => _period = o),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6C5CE7) : const Color(0xFF161936),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                o,
                style: TextStyle(color: sel ? Colors.white : Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, double> _calculateMonthlyTotals(List<Expense> items) {
    final now = DateTime.now();
    int months = 12;
    if (_period == '3 Months') months = 3;
    if (_period == '6 Months') months = 6;

    final Map<String, double> m = {};
    for (int i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM yy').format(d);
      m[key] = 0;
    }

    for (final e in items) {
      final key = DateFormat(
        'MMM yy',
      ).format(DateTime(e.date.year, e.date.month, 1));
      if (m.containsKey(key)) m[key] = (m[key] ?? 0) + e.amount;
    }
    return m;
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> items) {
    final totals = <String, double>{};
    for (final e in items) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Widget _buildLineChart(Map<String, double> monthly) {
    final entries = monthly.entries.toList();
    final spots = List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), entries[i].value),
    );

    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expenses over time',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, horizontalInterval: 1),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length)
                          return const SizedBox();
                        return Text(
                          entries[idx].key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF6C5CE7),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    Map<String, double> categoryTotals,
    CategoryProvider categoryProvider,
  ) {
    final entries = categoryTotals.entries.toList();
    // take top 6
    entries.sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top categories',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (top.isNotEmpty ? top.first.value : 0) * 1.1,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= top.length)
                          return const SizedBox();
                        return Text(
                          top[idx].key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(top.length, (i) {
                  final v = top[i].value;
                  final category = categoryProvider.categories.firstWhere(
                    (c) => c.name == top[i].key,
                    orElse: () => Category.defaultCategories.first,
                  );
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v,
                        color: category.color,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
