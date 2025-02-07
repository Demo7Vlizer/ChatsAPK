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

  @override
  void onInit() {
    super.onInit();
    print('ChatController: onInit');
    
    if (!Get.arguments.containsKey('userId')) {
      print('Error: No userId provided');
      Get.back();
      return;
    }

    otherUserId = Get.arguments['userId'];
    otherUserName = Get.arguments['userName'] ?? 'User';
    otherUserPhoto = Get.arguments['userPhoto'] ?? '';
    
    print('OtherUserId: $otherUserId');
    print('Current user: ${_authService.currentUser.value?.uid}');
    
    _initializeChat();
    _listenToUserStatus();
    ever(messages, (_) => _markMessagesAsRead());
  }

  Future<void> _initializeChat() async {
    try {
      isLoading.value = true;
      
      final users = [
        _authService.currentUser.value!.uid,
        otherUserId,
      ]..sort();
      
      chatRoomId = users.join('_');
      print('Initialized chat room: $chatRoomId');

      await _chatService.createChatRoom(
        _authService.currentUser.value!.uid,
        otherUserId,
      );

      // Update the query to order by timestamp ascending
      _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen(
        (snapshot) {
          print('Received messages: ${snapshot.docs.length}');
          final newMessages = snapshot.docs
              .map((doc) {
                print('Message data: ${doc.data()}');
                return MessageModel.fromMap(doc.data());
              })
              .toList();
          messages.assignAll(newMessages);
          print('Updated messages list: ${messages.length}');
        },
        onError: (error) {
          print('Error listening to messages: $error');
        },
      );

    } catch (e) {
      print('Error in _initializeChat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String receiverId, String content, MessageType type) async {
    if (content.trim().isEmpty) return;
    
    try {
      if (chatRoomId.isEmpty) {
        print('Error: ChatRoomId is empty');
        throw 'Chat room not initialized';
      }

      if (_authService.currentUser.value?.uid == null) {
        print('Error: Current user is null');
        throw 'User not authenticated';
      }

      await _chatService.sendMessage(
        chatRoomId,
        currentUserId,
        content.trim(),
      );
      
      messageController.clear();
      updateTypingStatus(receiverId, false);
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String get currentUserId => _authService.currentUser.value?.uid ?? '';

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
    return _firestore.collection('typing_status')
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

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }
} 