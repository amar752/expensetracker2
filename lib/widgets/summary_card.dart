import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SummaryCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final double? income;
  final double? balance;
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.income,
    this.balance,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFF6C5CE7).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (_isPressed)
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: const Color(0xFF6C5CE7), size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              // Show balance as main value
              Text(
                widget.balance != null
                    ? '${widget.balance! >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.balance)}'
                    : NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.value),
                style: TextStyle(
                  color: widget.balance != null
                      ? (widget.balance! >= 0 ? Colors.green : Colors.red)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Show expenses and income as details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${NumberFormat('#,##,###.##').format(widget.value)}',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.income != null && widget.income! > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+₹${NumberFormat('#,##,###.##').format(widget.income)}',
                            style: TextStyle(
                              color: Colors.green.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
