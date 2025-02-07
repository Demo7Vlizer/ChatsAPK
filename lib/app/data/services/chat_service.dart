import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';

class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Update last message in chat room
  Future<void> _updateLastMessage(String chatId, String message) async {
    await _firestore.collection('chat_rooms').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': DateTime.now().toIso8601String(),
    });
  }

  // Send message with real-time updates
  Future<void> sendMessage(String chatId, String senderId, String content) async {
    try {
      final timestamp = DateTime.now();
      
      // First verify chat room exists
      final chatRoom = await _firestore.collection('chat_rooms').doc(chatId).get();
      if (!chatRoom.exists) {
        throw 'Chat room not found';
      }

      final message = MessageModel(
        id: timestamp.millisecondsSinceEpoch.toString(),
        senderId: senderId,
        content: content,
        type: 'text',
        timestamp: timestamp,
        isRead: false,
      );

      // Use transaction to ensure both operations complete
      await _firestore.runTransaction((transaction) async {
        // Add message
        transaction.set(
          _firestore
              .collection('chat_rooms')
              .doc(chatId)
              .collection('messages')
              .doc(message.id),
          message.toMap(),
        );

        // Update chat room
        transaction.update(
          _firestore.collection('chat_rooms').doc(chatId),
          {
            'lastMessage': content,
            'lastMessageTime': timestamp.toIso8601String(),
            'lastMessageSenderId': senderId,
            'unreadCount': FieldValue.increment(1),
          },
        );
      });
    } catch (e) {
      print('Error in sendMessage: $e');
      throw 'Failed to send message';
    }
  }

  // Send image message
  Future<void> sendImage(String chatId, String senderId, File imageFile) async {
    // Upload image to Firebase Storage
    final ref = _storage.ref().child('chat_images/${DateTime.now()}.jpg');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      content: 'Image',
      type: 'image',
      timestamp: DateTime.now(),
      mediaUrl: imageUrl,
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _updateLastMessage(chatId, 'Image');
  }

  // Stream of messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Create or get chat room for two users
  Future<String> createChatRoom(String user1Id, String user2Id) async {
    try {
      final users = [user1Id, user2Id]..sort();
      final chatRoomId = users.join('_');

      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      final chatRoom = await chatRoomRef.get();

      if (!chatRoom.exists) {
        await chatRoomRef.set({
          'id': chatRoomId,
          'participants': users,
          'lastMessageTime': DateTime.now().toIso8601String(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'unreadCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return chatRoomId;
    } catch (e) {
      print('Error creating chat room: $e');
      throw 'Failed to create chat room';
    }
  }

  // Get all chat rooms for a user
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromMap(doc.data()))
            .toList());
  }

  // Get real-time chat room updates
  Stream<ChatRoomModel?> getChatRoom(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ChatRoomModel.fromMap(doc.data()!) : null);
  }
} 