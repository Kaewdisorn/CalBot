import 'package:get/get.dart';
import 'package:halulu/data/models/user_model.dart';
import 'package:halulu/data/providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  Future<UserModel> register({required String userName, required String userEmail, required String userPassword}) async {
    final Map<String, dynamic> requestBody = UserModel(userName: userName, userEmail: userEmail, userPassword: userPassword).toJson();
    final Map<String, dynamic> resData = await _authProvider.register(requestBody);
    print(resData);

    return UserModel();
  }
}
