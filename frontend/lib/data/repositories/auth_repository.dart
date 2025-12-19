import 'package:halulu/data/models/user_model.dart';

class AuthRepository {
  UserModel register({required String userName, required String userEmail, required String userPassword}) {
    print('Registering user: $userName, $userEmail');
    return UserModel();
  }
}
