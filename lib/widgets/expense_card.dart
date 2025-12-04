import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExpenseCard extends StatefulWidget {
  final String title;
  final double amount;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isIncome;
  const ExpenseCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.onTap,
    this.isIncome = false,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard>
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
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _animationController.reverse();
            widget.onTap?.call();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _animationController.reverse();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161936),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed
                      ? const Color(0xFF6C5CE7).withOpacity(0.5)
                      : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C5CE7).withOpacity(0.3),
                          const Color(0xFF8B7FFF).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF6C5CE7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
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
                        '${widget.isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.amount)}',
                        style: TextStyle(
                          color: widget.isIncome
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideX(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
