import 'package:get/get.dart';
import '../data/services/auth_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
  }
} 