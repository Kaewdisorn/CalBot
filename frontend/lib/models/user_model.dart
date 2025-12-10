class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.email, required this.age, required this.createdAt});

  // Factory constructor for creating a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'age': age, 'created_at': createdAt.toIso8601String()};
  }

  // CopyWith method for immutable updates
  User copyWith({String? id, String? name, String? email, int? age, DateTime? createdAt}) {
    return User(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email, age: age ?? this.age, createdAt: createdAt ?? this.createdAt);
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, age: $age, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.name == name && other.email == email && other.age == age && other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, age, createdAt);
  }
}
