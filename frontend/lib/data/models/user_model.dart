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
      if (gid != null) 'gid': gid,
      if (uid != null) 'uid': uid,
      if (userName != null) 'userName': userName,
      if (userEmail != null) 'userEmail': userEmail,
      if (userPassword != null) 'userPassword': userPassword,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      gid: json['gid'],
      uid: json['uid'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      userPassword: json['userPassword'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
