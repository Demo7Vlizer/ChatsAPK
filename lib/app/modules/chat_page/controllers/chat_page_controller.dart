import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChatPageController extends GetxController {
  final messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add some dummy messages
    messages.addAll([
      ChatMessage(
        text: "Hello, how are you?",
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
      ChatMessage(
        text: "I'm good, thanks! How about you?",
        time: DateTime.now().subtract(const Duration(minutes: 4)),
        isMe: true,
      ),
      ChatMessage(
        text: "I'm doing great! Would you like to catch up sometime?",
        time: DateTime.now().subtract(const Duration(minutes: 3)),
        isMe: false,
      ),
    ]);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(
      text: text,
      time: DateTime.now(),
      isMe: true,
    ));

    messageController.clear();
    isTyping.value = false;

    // Simulate received message after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      messages.add(ChatMessage(
        text: "This is a simulated response",
        time: DateTime.now(),
        isMe: false,
      ));
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class ChatMessage {
  final String text;
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}
