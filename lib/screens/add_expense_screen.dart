import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/balance_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories
              .where((c) => !c.isIncome)
              .toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAmountField()
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                _buildTitleField()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                _buildCategorySelector(categories)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                _buildDateSelector()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                _buildPaymentMethodSelector()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 400.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                _buildDescriptionField()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 500.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCalculator(BuildContext context) {
    String expr = '';

    double? tryEvaluate(String s) {
      try {
        final v = _evaluateExpression(s);
        return v;
      } catch (_) {
        return null;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: const Color(0xFF101225),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final result = tryEvaluate(expr);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161936),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expr.isEmpty ? '0' : expr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result == null
                              ? ''
                              : '= ${result.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCalcKeys((value) {
                    setState(() {
                      if (value == 'C') {
                        expr = '';
                      } else if (value == 'DEL') {
                        if (expr.isNotEmpty)
                          expr = expr.substring(0, expr.length - 1);
                      } else if (value == '=') {
                        final v = tryEvaluate(expr);
                        if (v != null) {
                          _amountController.text = v.toStringAsFixed(2);
                          Navigator.of(ctx).pop();
                        }
                      } else {
                        expr += value;
                      }
                    });
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            final v = tryEvaluate(expr);
                            if (v != null) {
                              _amountController.text = v.toStringAsFixed(2);
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: const Text(
                            'Use result',
                            style: TextStyle(color: Color(0xFF6C5CE7)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalcKeys(void Function(String) onKey) {
    final keys = [
      '7',
      '8',
      '9',
      '/',
      '4',
      '5',
      '6',
      '*',
      '1',
      '2',
      '3',
      '-',
      '0',
      '.',
      '=',
      '+',
      'C',
      'DEL',
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: keys.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final k = keys[index];
        return ElevatedButton(
          onPressed: () => onKey(k),
          style: ElevatedButton.styleFrom(
            backgroundColor: k == '='
                ? const Color(0xFF6C5CE7)
                : const Color(0xFF161936),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            k,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      },
    );
  }

  double _evaluateExpression(String input) {
    // Tokenize
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        buffer.write(ch);
      } else if (RegExp(r'[+\-*/()]').hasMatch(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(ch);
      } else if (ch.trim().isEmpty) {
        continue;
      } else {
        throw FormatException('Invalid character: $ch');
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());

    if (tokens.isEmpty) throw FormatException('Empty expression');

    // Shunting-yard to RPN
    final out = <String>[];
    final ops = <String>[];

    int prec(String op) {
      if (op == '+' || op == '-') return 1;
      if (op == '*' || op == '/') return 2;
      return 0;
    }

    bool isOperator(String t) => '+-*/'.contains(t);

    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (double.tryParse(t) != null) {
        out.add(t);
      } else if (isOperator(t)) {
        while (ops.isNotEmpty &&
            isOperator(ops.last) &&
            prec(ops.last) >= prec(t)) {
          out.add(ops.removeLast());
        }
        ops.add(t);
      } else if (t == '(') {
        ops.add(t);
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') out.add(ops.removeLast());
        if (ops.isEmpty || ops.last != '(')
          throw FormatException('Mismatched parentheses');
        ops.removeLast();
      } else {
        throw FormatException('Unknown token: $t');
      }
    }
    while (ops.isNotEmpty) {
      final o = ops.removeLast();
      if (o == '(' || o == ')') throw FormatException('Mismatched parentheses');
      out.add(o);
    }

    // Evaluate RPN
    final stack = <double>[];
    for (final token in out) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else if (isOperator(token)) {
        if (stack.length < 2) throw FormatException('Invalid expression');
        final b = stack.removeLast();
        final a = stack.removeLast();
        double res;
        switch (token) {
          case '+':
            res = a + b;
            break;
          case '-':
            res = a - b;
            break;
          case '*':
            res = a * b;
            break;
          case '/':
            res = a / b;
            break;
          default:
            throw FormatException('Unknown operator $token');
        }
        stack.add(res);
      } else {
        throw FormatException('Invalid token in RPN: $token');
      }
    }
    if (stack.length != 1) throw FormatException('Invalid expression result');
    return stack.single;
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: const TextStyle(color: Colors.white30),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calculate, color: Colors.white70),
                onPressed: () => _openCalculator(context),
                tooltip: 'Open calculator',
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final cleanValue = value
                  .replaceAll(',', '')
                  .replaceAll('₹', '')
                  .replaceAll(' ', '')
                  .trim();
              final parsed = double.tryParse(cleanValue);
              if (parsed == null) {
                return 'Please enter a valid number';
              }
              if (parsed <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Category',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '(Optional)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategory?.name == category.name;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              category.color.withOpacity(0.4),
                              category.color.withOpacity(0.2),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? category.color : Colors.white30,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: isSelected ? category.color : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161936),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = ['Cash', 'Card', 'Bank Transfer', 'UPI', 'Digital Wallet'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: methods.map((method) {
              final isSelected = _paymentMethod == method;
              return ChoiceChip(
                label: Text(method),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _paymentMethod = method;
                  });
                },
                selectedColor: const Color(0xFF6C5CE7),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6C5CE7) : Colors.white30,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161936),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _descriptionController,
        style: const TextStyle(color: Colors.white),
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Description (Optional)',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return _AnimatedSaveButton(onPressed: _saveExpense);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C5CE7),
              surface: Color(0xFF161936),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() async {
    debugPrint('_saveExpense called');
    try {
      if (!_formKey.currentState!.validate()) {
        debugPrint('Form validation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }
      debugPrint('Form validation passed');

      final rawAmountText = _amountController.text
          .replaceAll(',', '')
          .replaceAll('₹', '')
          .trim();
      final parsedAmount = double.tryParse(rawAmountText);

      if (parsedAmount == null || parsedAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount greater than 0'),
          ),
        );
        return;
      }

      final expense = Expense(
        title: _titleController.text.trim(),
        amount: parsedAmount,
        category: _selectedCategory?.name ?? 'Uncategorized',
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      // Check balance before saving: if expense > available balance, show error.
      final balanceProvider = context.read<BalanceProvider>();
      final currentBalance = balanceProvider.totalBalance;
      if (parsedAmount > currentBalance) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
        return;
      }

      // Save the expense (centralized balance update in provider)
      debugPrint('Saving expense: ${expense.title}, ₹${expense.amount}');
      await context.read<ExpenseProvider>().addExpense(
        expense,
        balanceProvider,
      );
      debugPrint('Expense saved successfully');

      if (!mounted) return;

      // Show success dialog
      // Show success dialog (don't await) so we can close it programmatically
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/success.json',
                    repeat: false,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 80,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Saved!', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      );

      // Wait a bit then close dialog and navigate back
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Close the dialog, then the add-expense screen
      Navigator.of(context).pop(); // Close success dialog
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) Navigator.of(context).pop(); // Close add expense screen
    } catch (e) {
      debugPrint('Error saving expense: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving expense: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _AnimatedSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedSaveButton({required this.onPressed});

  @override
  State<_AnimatedSaveButton> createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _animationController.forward();
            HapticFeedback.mediumImpact();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _animationController.reverse();
            // Delay to let animation complete, then call onPressed
            Future.delayed(const Duration(milliseconds: 100), () {
              widget.onPressed();
            });
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _animationController.reverse();
          },
          // No onTap fallback — onTapUp already triggers the action after animation
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8B7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: _isPressed ? 15 : 20,
                    spreadRadius: _isPressed ? 2 : 0,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Save Expense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .scaleXY(
          begin: 0.95,
          end: 1.0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}
