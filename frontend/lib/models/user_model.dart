class UserModel {
  final String gid;
  final String uid;
  final String token;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.gid,
    required this.uid,
    required this.token,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      gid: json['gid'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'gid': gid,
  //     'uid': uid,
  //     'token': token,
  //     'email': email,
  //     'password': password,
  //     'created_at': createdAt.toIso8601String(),
  //     'updated_at': updatedAt.toIso8601String(),
  //   };
  // }

  UserModel copyWith({String? gid, String? uid, String? token, String? email, String? password, DateTime? createdAt, DateTime? updatedAt}) {
    return UserModel(
      gid: gid ?? this.gid,
      uid: uid ?? this.uid,
      token: token ?? this.token,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
