class UserModel {
  final String? gid;
  final String? uid;
  final String? userName;
  final String? userEmail;
  final String? userPassword;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({this.gid, this.uid, this.userName, this.userEmail, this.userPassword, this.createdAt, this.updatedAt});

  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
      'uid': uid,
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
