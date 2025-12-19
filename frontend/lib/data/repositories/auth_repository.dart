import 'package:halulu/data/models/user_model.dart';

class AuthRepository {
  UserModel register({required String userName, required String userEmail, required String userPassword}) {
    final Map<String, dynamic> requestBody = UserModel(userName: userName, userEmail: userEmail, userPassword: userPassword).toJson();

    return UserModel();
  }
}
