import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;
  final double? budgetLimit;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isIncome = false,
    this.budgetLimit,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'color': color.toARGB32(),
    'isIncome': isIncome ? 1 : 0,
    'budgetLimit': budgetLimit,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'] as int?,
    name: map['name'] as String,
    icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
    color: Color(map['color'] as int),
    isIncome: (map['isIncome'] as int) == 1,
    budgetLimit: (map['budgetLimit'] as num?)?.toDouble(),
  );

  static const defaultCategories = <Category>[
    Category(name: 'Food', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
    Category(
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF4ECDC4),
    ),
    Category(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFF95E77E),
    ),
    Category(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFFD93D),
    ),
    Category(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFF6C5CE7)),
    Category(
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Color(0xFFA8E6CF),
    ),
    Category(name: 'Education', icon: Icons.school, color: Color(0xFFFFAEC9)),
    // Income categories
    Category(
      name: 'Salary',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF4CAF50),
      isIncome: true,
    ),
    Category(
      name: 'Freelance',
      icon: Icons.work_outline,
      color: Color(0xFF66BB6A),
      isIncome: true,
    ),
    Category(
      name: 'Business',
      icon: Icons.business_center,
      color: Color(0xFF26A69A),
      isIncome: true,
    ),
    Category(
      name: 'Investment',
      icon: Icons.trending_up,
      color: Color(0xFF42A5F5),
      isIncome: true,
    ),
    Category(
      name: 'Bonus',
      icon: Icons.card_giftcard,
      color: Color(0xFF9CCC65),
      isIncome: true,
    ),
    Category(
      name: 'Gift',
      icon: Icons.redeem,
      color: Color(0xFFAB47BC),
      isIncome: true,
    ),
    Category(
      name: 'Refund',
      icon: Icons.replay,
      color: Color(0xFF29B6F6),
      isIncome: true,
    ),
    Category(
      name: 'Other Income',
      icon: Icons.attach_money,
      color: Color(0xFF66BB6A),
      isIncome: true,
    ),
  ];
}
