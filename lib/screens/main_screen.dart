import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'categories_screen.dart';
import 'graphs_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _fabExpanded = false;
  bool _hoverExpense = false;
  bool _hoverIncome = false;
  bool _fabBusy = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InsightsScreen(),
    const GraphsScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Defensive: ensure current index is within bounds if code changes the
    // number of tabs/screens dynamically.
    if (_currentIndex >= _screens.length) {
      _currentIndex = _screens.length - 1;
    }
    return Scaffold(
      backgroundColor: const Color(0xFF101225),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _currentIndex == 0
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_fabExpanded) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _hoverExpense ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Expense',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MouseRegion(
                        onEnter: (_) => setState(() => _hoverExpense = true),
                        onExit: (_) => setState(() => _hoverExpense = false),
                        child: FloatingActionButton.small(
                          heroTag: 'main_add_expense',
                          onPressed: () {
                            setState(() => _fabExpanded = false);
                            Navigator.pushNamed(context, '/add');
                          },
                          backgroundColor: Colors.redAccent,
                          child: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Add Expense',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _hoverIncome ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Income',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MouseRegion(
                        onEnter: (_) => setState(() => _hoverIncome = true),
                        onExit: (_) => setState(() => _hoverIncome = false),
                        child: FloatingActionButton.small(
                          heroTag: 'main_add_income',
                          onPressed: () {
                            setState(() => _fabExpanded = false);
                            Navigator.pushNamed(context, '/income');
                          },
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.add_circle_outline),
                          tooltip: 'Add Income',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton(
                  heroTag: 'main_fab',
                  backgroundColor: const Color(0xFF6C5CE7),
                  onPressed: () async {
                    if (_fabBusy) return;
                    setState(() => _fabBusy = true);
                    debugPrint(
                      'MainScreen FAB pressed, expanded=$_fabExpanded',
                    );
                    setState(() => _fabExpanded = !_fabExpanded);
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (mounted) setState(() => _fabBusy = false);
                  },
                  child: AnimatedRotation(
                    turns: _fabExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161936),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            if (index < 0 || index >= _screens.length) {
              // clamp to valid range
              _currentIndex = _screens.length - 1;
            } else {
              _currentIndex = index;
            }
          }),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C5CE7),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Graphs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
          ],
        ),
      ),
    );
  }
}
