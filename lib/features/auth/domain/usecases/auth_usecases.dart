import 'package:smartmedia_campaign_manager/features/auth/data/models/user_model.dart';
import 'package:smartmedia_campaign_manager/features/auth/data/repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository authRepository;

  AuthUseCases({required this.authRepository});

  Future<String> login(
      {required String email, required String password}) async {
    return await authRepository.login(email: email, password: password);
  }

  Future<String> register(
      {required String email,
      required String password,
      required int phoneNumber,
      required String firstName,
      String? profileImage,
      required String lastName}) async {
    return await authRepository.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        firstName: firstName,
        lastName: lastName);
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<User?> getCurrentUserDetails() async {
    return await authRepository.getCurrentUserDetails();
  }

  bool isUserSignedIn() {
    return authRepository.isUserSignedIn();
  }

  String? getCurrentUserId() {
    return authRepository.getCurrentUserId();
  }
}
