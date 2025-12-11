class User {
  final String gid;
  final String uid;
  final String userEmail;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({required this.gid, required this.uid, required this.userEmail, required this.password, required this.createdAt, required this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      gid: json['gid'] as String,
      uid: json['uid'] as String,
      userEmail: json['userEmail'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
      'uid': uid,
      'userEmail': userEmail,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({String? gid, String? uid, String? userEmail, String? password, DateTime? createdAt, DateTime? updatedAt}) {
    return User(
      gid: gid ?? this.gid,
      uid: uid ?? this.uid,
      userEmail: userEmail ?? this.userEmail,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
