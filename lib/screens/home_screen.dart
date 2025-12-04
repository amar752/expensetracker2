import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/user_provider.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _fabExpanded = false;
  bool _hoverExpense = false;
  bool _hoverIncome = false;
  bool _fabBusy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load users first so DatabaseHelper can switch to the correct per-user DB
      context.read<UserProvider>().load().then((_) {
        // Now load expense/category/balance data from the selected user's DB
        context.read<ExpenseProvider>().load();
        context.read<CategoryProvider>().load();
        context.read<BalanceProvider>().load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101225),
      body: SafeArea(
        child: Consumer3<ExpenseProvider, CategoryProvider, BalanceProvider>(
          builder:
              (context, expenseProvider, categoryProvider, balanceProvider, _) {
                // Calculate expenses and income separately
                final allExpenses = expenseProvider.items;
                final categories = categoryProvider.categories;

                final expenses = allExpenses.where((e) {
                  final category = categories.firstWhere(
                    (c) => c.name == e.category,
                    orElse: () => categories.firstWhere(
                      (c) => c.isIncome == false,
                      orElse: () => Category.defaultCategories[0],
                    ),
                  );
                  return !category.isIncome;
                }).toList();

                final incomes = allExpenses.where((e) {
                  final category = categories.firstWhere(
                    (c) => c.name == e.category,
                    orElse: () => categories.firstWhere(
                      (c) => c.isIncome == true,
                      orElse: () => Category.defaultCategories.last,
                    ),
                  );
                  return category.isIncome;
                }).toList();

                final totalExpenses = expenses.fold<double>(
                  0,
                  (sum, item) => sum + item.amount,
                );
                final totalIncome = incomes.fold<double>(
                  0,
                  (sum, item) => sum + item.amount,
                );
                final remainingBalance = balanceProvider
                    .calculateRemainingBalance(totalExpenses, totalIncome);

                final todayExpenses = expenses
                    .where((e) {
                      final today = DateTime.now();
                      return e.date.year == today.year &&
                          e.date.month == today.month &&
                          e.date.day == today.day;
                    })
                    .fold<double>(0, (sum, item) => sum + item.amount);

                final todayIncome = incomes
                    .where((e) {
                      final today = DateTime.now();
                      return e.date.year == today.year &&
                          e.date.month == today.month &&
                          e.date.day == today.day;
                    })
                    .fold<double>(0, (sum, item) => sum + item.amount);

                // Calculate this month's expenses and income
                final monthExpenses = expenses
                    .where((e) {
                      final now = DateTime.now();
                      return e.date.year == now.year &&
                          e.date.month == now.month;
                    })
                    .fold<double>(0, (sum, item) => sum + item.amount);

                final monthIncome = incomes
                    .where((e) {
                      final now = DateTime.now();
                      return e.date.year == now.year &&
                          e.date.month == now.month;
                    })
                    .fold<double>(0, (sum, item) => sum + item.amount);

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      expenseProvider.load(),
                      categoryProvider.load(),
                      balanceProvider.load(),
                    ]);
                  },
                  color: const Color(0xFF6C5CE7),
                  backgroundColor: const Color(0xFF161936),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, balanceProvider),
                              const SizedBox(height: 24),
                              _buildBalanceCard(
                                remainingBalance,
                                balanceProvider.totalBalance,
                                totalExpenses,
                                totalIncome,
                              ),
                              const SizedBox(height: 20),
                              _buildQuickStats(
                                todayExpenses,
                                todayIncome,
                                monthExpenses,
                                monthIncome,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Recent Transactions', () {
                                Navigator.pushNamed(context, '/expenses');
                              }),
                            ],
                          ),
                        ),
                      ),
                      _buildRecentTransactions(
                        expenseProvider,
                        categoryProvider,
                      ),
                    ],
                  ),
                );
              },
        ),
      ),
      floatingActionButton: Column(
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
                    heroTag: 'home_add_expense',
                    onPressed: () {
                      setState(() => _fabExpanded = false);
                      Navigator.pushNamed(context, '/add').then((_) {
                        if (mounted) context.read<ExpenseProvider>().load();
                      });
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
                    heroTag: 'home_add_income',
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
            heroTag: 'home_main_fab',
            backgroundColor: const Color(0xFF6C5CE7),
            onPressed: () async {
              if (_fabBusy) return;
              setState(() => _fabBusy = true);
              debugPrint('Main FAB pressed, expanded=$_fabExpanded');
              setState(() => _fabExpanded = !_fabExpanded);
              // small debounce to avoid re-entrancy
              await Future.delayed(const Duration(milliseconds: 200));
              if (mounted) setState(() => _fabBusy = false);
            },
            child: AnimatedRotation(
              turns: _fabExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BalanceProvider balanceProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show current user's name when available
            Builder(
              builder: (context) {
                final user = context.watch<UserProvider>().currentUser;
                final welcome = user != null
                    ? 'Welcome back, ${user.name}!'
                    : 'Welcome back!';
                return Text(
                  welcome,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Expenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showBalanceDialog(context, balanceProvider),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161936),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
            // Profile button
            IconButton(
              onPressed: () => _showProfileDialog(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161936),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              tooltip: 'Profile',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    double remainingBalance,
    double totalBalance,
    double totalExpenses,
    double totalIncome,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF8B7FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  if (totalBalance > 0)
                    Text(
                      'Initial: ₹${NumberFormat('#,##,###.##').format(totalBalance)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
            ).format(remainingBalance),
            style: TextStyle(
              color: remainingBalance >= 0
                  ? Colors.white
                  : const Color(0xFFFF6B6B),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalExpenses > 0 || totalIncome > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '+₹${NumberFormat('#,##,###.##').format(totalIncome)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Expenses',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '-₹${NumberFormat('#,##,###.##').format(totalExpenses)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    double todayExpenses,
    double todayIncome,
    double monthExpenses,
    double monthIncome,
  ) {
    // Calculate net balance for today and this month
    final todayBalance = todayIncome - todayExpenses;
    final monthBalance = monthIncome - monthExpenses;
    
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: 'Today',
            value: todayExpenses,
            icon: Icons.today,
            income: todayIncome,
            balance: todayBalance,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            title: 'This Month',
            value: monthExpenses,
            icon: Icons.calendar_month,
            income: monthIncome,
            balance: monthBalance,
          ),
        ),
      ],
    );
  }

  void _showBalanceDialog(
    BuildContext context,
    BalanceProvider balanceProvider,
  ) {
    final controller = TextEditingController(
      text: balanceProvider.totalBalance > 0
          ? balanceProvider.totalBalance.toStringAsFixed(2)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161936),
        title: const Text(
          'Set Total Balance',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Balance (₹)',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixText: '₹ ',
            prefixStyle: const TextStyle(
              color: Color(0xFF6C5CE7),
              fontSize: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                balanceProvider.setBalance(value);
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  void _showProfileDialog(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    
    if (currentUser == null) return;
    
    final nameController = TextEditingController(text: currentUser.name);
    final emailController = TextEditingController(text: currentUser.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161936),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF6C5CE7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF6C5CE7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white30),
            const SizedBox(height: 8),
            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showResetConfirmationDialog(context);
                },
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                label: const Text(
                  'Reset All Data',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }
              
              // Update user in database
              final updatedUser = User(
                id: currentUser.id,
                name: newName,
                email: emailController.text.trim().isEmpty 
                    ? null 
                    : emailController.text.trim(),
                createdAt: currentUser.createdAt,
              );
              
              // Delete old user and add updated one
              await userProvider.deleteUser(currentUser);
              await userProvider.addUser(
                updatedUser.name,
                email: updatedUser.email,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161936),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            const Text(
              'Reset All Data?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete:\n\n'
          '• Your profile\n'
          '• All expenses and income\n'
          '• All categories\n'
          '• Balance information\n\n'
          'This action cannot be undone!',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performReset(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              'Reset Everything',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(BuildContext context) async {
    try {
      final userProvider = context.read<UserProvider>();
      final expenseProvider = context.read<ExpenseProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final balanceProvider = context.read<BalanceProvider>();
      
      // Delete current user (this will also clear their data)
      if (userProvider.currentUser != null) {
        await userProvider.deleteUser(userProvider.currentUser!);
      }
      
      // Clear all providers
      await Future.wait([
        expenseProvider.load(),
        categoryProvider.load(),
        balanceProvider.load(),
      ]);
      
      if (context.mounted) {
        // Navigate to user setup screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_setup',
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(color: Color(0xFF6C5CE7)),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    ExpenseProvider provider,
    CategoryProvider categoryProvider,
  ) {
    final recentExpenses = provider.items.take(5).toList();

    if (recentExpenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset('assets/lottie/empty.json', repeat: true),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final expense = recentExpenses[index];
        final category = categoryProvider.categories.firstWhere(
          (c) => c.name == expense.category,
          orElse: () => Category.defaultCategories.first,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: ExpenseCard(
            title: expense.title,
            amount: expense.amount,
            isIncome: category.isIncome,
            subtitle:
                '${expense.category} • ${DateFormat('MMM dd').format(expense.date)}',
            onTap: () {
              // Optional: Navigate to expense details or edit
            },
          ),
        );
      }, childCount: recentExpenses.length),
    );
  }
}
