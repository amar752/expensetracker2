class User {
  final int? id;
  final String name;
  final String? email;
  final DateTime createdAt;

  User({this.id, required this.name, this.email, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, Object?> m) => User(
    id: m['id'] as int?,
    name: (m['name'] as String?) ?? 'Unnamed',
    email: m['email'] as String?,
    createdAt:
        DateTime.tryParse((m['createdAt'] as String?) ?? '') ?? DateTime.now(),
  );
}
