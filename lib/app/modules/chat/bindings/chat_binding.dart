import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../../data/services/chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService());
    Get.lazyPut<ChatController>(() => ChatController());
  }
} 