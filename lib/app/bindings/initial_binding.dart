import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../data/services/chat_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(ChatService());
  }
} 