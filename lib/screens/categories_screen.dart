import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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
        title: const Text('Categories', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final expenseCategories = provider.categories
              .where((c) => !c.isIncome)
              .toList();
          final incomeCategories = provider.categories
              .where((c) => c.isIncome)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCategorySection(
                'Expense Categories',
                expenseCategories,
                false,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                'Income Categories',
                incomeCategories,
                true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Category> categories,
    bool isIncome,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return _buildAddCategoryCard(isIncome);
            }

            final category = categories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return _InteractiveCategoryCard(category: category);
  }

  Widget _buildAddCategoryCard(bool isIncome) {
    return _InteractiveAddCard(
      isIncome: isIncome,
      onTap: () => _showAddCategoryDialog(context, isIncome: isIncome),
    );
  }

  void _showAddCategoryDialog(BuildContext context, {bool isIncome = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161936),
        title: Text(
          'Add ${isIncome ? "Income" : "Expense"} Category',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Category management coming soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF6C5CE7))),
          ),
        ],
      ),
    );
  }
}

class _InteractiveCategoryCard extends StatefulWidget {
  final Category category;
  const _InteractiveCategoryCard({required this.category});

  @override
  State<_InteractiveCategoryCard> createState() =>
      _InteractiveCategoryCardState();
}

class _InteractiveCategoryCardState extends State<_InteractiveCategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.mediumImpact();
            // Add category details or edit functionality
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF161936),
                    widget.category.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed
                      ? widget.category.color.withOpacity(0.6)
                      : widget.category.color.withOpacity(0.3),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: widget.category.color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.category.color.withOpacity(
                            _isPressed ? 0.4 : 0.2,
                          ),
                          widget.category.color.withOpacity(
                            _isPressed ? 0.3 : 0.1,
                          ),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.category.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: widget.category.color,
                      size: _isPressed ? 26 : 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: _isPressed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (widget.category.budgetLimit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.category.budgetLimit!.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: ((widget.category.id ?? 0) * 50).ms)
        .scaleXY(begin: 0.9, end: 1.0, duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _InteractiveAddCard extends StatefulWidget {
  final bool isIncome;
  final VoidCallback onTap;
  const _InteractiveAddCard({required this.isIncome, required this.onTap});

  @override
  State<_InteractiveAddCard> createState() => _InteractiveAddCardState();
}

class _InteractiveAddCardState extends State<_InteractiveAddCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF161936),
                    const Color(0xFF6C5CE7).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed
                      ? const Color(0xFF6C5CE7).withOpacity(0.6)
                      : Colors.white.withOpacity(0.2),
                  width: _isPressed ? 2 : 1,
                  style: BorderStyle.solid,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(
                            0xFF6C5CE7,
                          ).withOpacity(_isPressed ? 0.4 : 0.2),
                          const Color(
                            0xFF8B7FFF,
                          ).withOpacity(_isPressed ? 0.3 : 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withOpacity(_isPressed ? 1.0 : 0.7),
                      size: _isPressed ? 26 : 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white.withOpacity(_isPressed ? 1.0 : 0.7),
                      fontSize: 12,
                      fontWeight: _isPressed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.9, end: 1.0, duration: 400.ms, curve: Curves.easeOut);
  }
}
