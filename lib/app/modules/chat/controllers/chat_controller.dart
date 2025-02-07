import 'package:get/get.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/message_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/config/app_config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final isLoading = false.obs;

  late String chatRoomId;
  late String otherUserId;

  final RxBool isTyping = false.obs;
  Timer? _typingTimer;

  final messageController = TextEditingController();
  late String otherUserName;
  late String otherUserPhoto;

  final RxBool isOtherUserOnline = false.obs;

  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('Testing API Key: ${AppConfig.googleApiKey}');
    _initializeController();
  }

  void _initializeController() {
    try {
      if (Get.arguments == null) {
        throw 'No arguments provided';
      }

      final userId = Get.arguments['userId'];
      if (userId == null || userId.toString().isEmpty) {
        throw 'Invalid userId';
      }

      otherUserId = userId.toString();
      otherUserName = Get.arguments['userName']?.toString() ?? 'User';
      otherUserPhoto = Get.arguments['userPhoto']?.toString() ?? '';

      print('OtherUserId: $otherUserId');
      print('Current user: ${_authService.currentUser.value?.uid}');

      _initializeChat();
      _listenToUserStatus();
      ever(messages, (_) => _markMessagesAsRead());

      isInitialized.value = true;
    } catch (e) {
      print('Error initializing chat: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize chat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  Future<void> _initializeChat() async {
    try {
      isLoading.value = true;

      if (_authService.currentUser.value?.uid == null) {
        throw 'User not authenticated';
      }

      final users = [
        _authService.currentUser.value!.uid,
        otherUserId,
      ]..sort();
      chatRoomId = users.join('_');

      await _firestore.collection('chat_rooms').doc(chatRoomId).set({
        'participants': users,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Listen to messages in real-time
      _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .listen(
        (snapshot) {
          try {
            messages.clear();
            for (var doc in snapshot.docs) {
              try {
                final message = MessageModel.fromMap(doc.data(), doc.id);
                messages.add(message);
              } catch (e) {
                print('Error parsing message: $e');
              }
            }
            print('Messages loaded: ${messages.length}');
          } catch (e) {
            print('Error processing messages: $e');
          }
        },
        onError: (error) {
          print('Error listening to messages: $error');
        },
      );
    } catch (e) {
      print('Error in _initializeChat: $e');
      Get.snackbar('Error', 'Failed to initialize chat');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(
      String receiverId, String content, MessageType type) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(chatRoomId, currentUserId, content);
      messageController.clear();
      updateTypingStatus(receiverId, false);
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sendImage(File imageFile) async {
    try {
      isLoading.value = true;
      await _chatService.sendImage(chatRoomId, currentUserId, imageFile);
    } catch (e) {
      print('Error sending image: $e');
      Get.snackbar(
        'Error',
        'Failed to send image',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get currentUserId => _authService.currentUser.value?.uid ?? '';

  String get currentChatId => chatRoomId;

  void onTyping() {
    isTyping.value = true;
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      isTyping.value = false;
    });
  }

  void _listenToUserStatus() {
    _firestore
        .collection('users')
        .doc(otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        isOtherUserOnline.value = snapshot.data()?['isOnline'] ?? false;
      }
    });
  }

  void _markMessagesAsRead() {
    if (messages.isEmpty) return;

    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });

    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({'unreadCount': 0});
  }

  void updateTypingStatus(String receiverId, bool typing) {
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

    _firestore.collection('typing_status').doc(currentUserId).set({
      'isTyping': typing,
      'timestamp': FieldValue.serverTimestamp(),
      'receiverId': receiverId,
    });

    if (typing) {
      _typingTimer = Timer(const Duration(seconds: 5), () {
        updateTypingStatus(receiverId, false);
      });
    }
  }

  Stream<bool> getTypingStatus(String userId) {
    return _firestore
        .collection('typing_status')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data()!;
      if (data['receiverId'] != currentUserId) return false;

      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final diff = DateTime.now().difference(timestamp);
      return data['isTyping'] && diff.inSeconds < 6;
    });
  }

  Future<void> deleteMessage(MessageModel message) async {
    try {
      if (message.senderId != currentUserId) {
        throw 'You can only delete your own messages';
      }

      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .delete();

      messages.removeWhere((m) => m.id == message.id);

      // Get.snackbar(
      //   'Success',
      //   'Message deleted successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      // );
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar(
        'Error',
        'Failed to delete message: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }
}
