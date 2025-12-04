class Budget {
  final int? id;
  final String category;
  final double limit;
  final String period; // month, week

  const Budget({
    this.id,
    required this.category,
    required this.limit,
    required this.period,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'limit_amount': limit,
    'period': period,
  };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    id: map['id'] as int?,
    category: map['category'] as String,
    limit: (map['limit_amount'] as num).toDouble(),
    period: map['period'] as String,
  );
}
