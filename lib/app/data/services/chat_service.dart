import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Add Cloudinary instance with your credentials
  final cloudinary = CloudinaryPublic(
    'dt2jjyafx', // Your cloud name
    'chat_images_preset', // Your unsigned upload preset name
    cache: false,
  );

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
      final message = {
        'senderId': senderId,
        'receiverId': chatId.split('_').firstWhere((id) => id != senderId),
        'content': content.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'type': MessageType.text.index,
        'status': MessageStatus.sent.index,
        'isRead': false,
      };

      await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .add(message);
    } catch (e) {
      print('Error in ChatService.sendMessage: $e');
      throw 'Failed to send message: $e';
    }
  }

  // Send image message
  Future<void> sendImage(String chatId, String senderId, File imageFile) async {
    try {
      print('Starting image upload to Cloudinary...');

      // Upload to Cloudinary with error handling
      CloudinaryResponse response;
      try {
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'chat_images',
          ),
        );
        print('Cloudinary upload successful: ${response.secureUrl}');
      } catch (cloudinaryError) {
        print('Cloudinary upload error: $cloudinaryError');
        throw 'Failed to upload image to Cloudinary: $cloudinaryError';
      }

      // Create message data with Cloudinary URL
      final message = {
        'senderId': senderId,
        'receiverId': chatId.split('_').firstWhere((id) => id != senderId),
        'content': response.secureUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'type': MessageType.image.index,
        'status': MessageStatus.sent.index,
        'isRead': false,
      };

      print('Saving to Firestore...');
      await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .add(message);

      print('Updating chat room metadata...');
      await _firestore.collection('chat_rooms').doc(chatId).update({
        'lastMessage': '📷 Image',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': senderId,
      });

      print('Image sent successfully!');
    } catch (e, stackTrace) {
      print('Error in sendImage: $e');
      print('Stack trace: $stackTrace');
      throw 'Failed to send image: $e';
    }
  }

  // Stream of messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
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

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'content': 'This message was deleted',
      });
    } catch (e) {
      print('Error deleting message: $e');
      throw 'Failed to delete message';
    }
  }
} 