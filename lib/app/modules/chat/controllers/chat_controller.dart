import 'package:get/get.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/message_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  
  late String chatRoomId;
  late String otherUserId;

  final RxBool isTyping = false.obs;
  Timer? _typingTimer;

  final messageController = TextEditingController();
  late String otherUserName;
  late String otherUserPhoto;

  final RxBool isOtherUserOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    otherUserId = Get.arguments['userId'];
    otherUserName = Get.arguments['userName'] ?? 'User';
    otherUserPhoto = Get.arguments['userPhoto'] ?? '';
    _initializeChat();
    _listenToUserStatus();
    ever(messages, (_) => _markMessagesAsRead());
  }

  Future<void> _initializeChat() async {
    try {
      isLoading.value = true;
      chatRoomId = await _chatService.createChatRoom(
        _authService.currentUser.value!.uid,
        otherUserId,
      );
      
      // Verify chat room was created
      final chatRoom = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .get();
          
      if (!chatRoom.exists) {
        throw 'Failed to create chat room';
      }

      // Listen to messages
      _chatService.getMessages(chatRoomId).listen(
        (msgs) {
          messages.value = msgs;
        },
        onError: (error) {
          print('Error listening to messages: $error');
          Get.snackbar(
            'Error',
            'Failed to load messages',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      print('Error in _initializeChat: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      await _chatService.sendMessage(
        chatRoomId,
        _authService.currentUser.value!.uid,
        content,
      );
      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? get currentUserId => _authService.currentUser.value?.uid;

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

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }
} 