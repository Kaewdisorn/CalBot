class User {
  final String gid;
  final String uid;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({required this.gid, required this.uid, required this.email, required this.password, required this.createdAt, required this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      gid: json['gid'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'gid': gid, 'uid': uid, 'email': email, 'password': password, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String()};
  }

  User copyWith({String? gid, String? uid, String? email, String? password, DateTime? createdAt, DateTime? updatedAt}) {
    return User(
      gid: gid ?? this.gid,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
