import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final RxString userName = 'User'.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.name;
    }
  }

  void signOut() async {
    await _authService.signOut();
    Get.offAllNamed('/onboarding');
  }
} 