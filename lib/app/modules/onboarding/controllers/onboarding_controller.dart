import 'package:get/get.dart';
import 'package:my/app/routes/app_pages.dart';
import '../../../data/services/auth_service.dart';
// import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final success = await _authService.signInWithGoogle();
      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          'Failed to sign in',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 