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

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
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
        title: const Text('Add Income', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories
              .where((c) => c.isIncome)
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
          const Text(
            'Category',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
    return _SimpleSaveButton(onPressed: _saveIncome);
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

  void _saveIncome() async {
    try {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

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

      final income = Expense(
        title: _titleController.text.trim(),
        amount: parsedAmount,
        category: _selectedCategory?.name ?? 'Salary',
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      final balanceProvider = context.read<BalanceProvider>();
      await context.read<ExpenseProvider>().addIncome(income, balanceProvider);

      if (!mounted) return;

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
                  const Text(
                    'Income added!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error saving income: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving income: $e')));
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

class _SimpleSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SimpleSaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF6C5CE7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Center(
        child: Text(
          'Save Income',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
