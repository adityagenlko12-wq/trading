import 'package:get/get.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';

import '../../repo/auth/signup_repo.dart';

class AuthenticationController extends GetxController with GetSingleTickerProviderStateMixin {
  LoginRepo loginRepo;
  RegistrationRepo registrationRepo;
  AuthenticationController({required this.loginRepo, required this.registrationRepo});

}
