import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my/app/core/config/cloudinary_config.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../exceptions/chat_exception.dart';

class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update Cloudinary configuration
  final cloudinary = CloudinaryPublic(
    'dtja0hsoy',  // Your cloud name
    'chat_preset',  // Must match exactly with your preset name
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
  Future<void> sendMessage(
      String chatId, String senderId, String content) async {
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

      await _updateLastMessage(chatId, content);
    } catch (e) {
      print('Error in ChatService.sendMessage: $e');
      throw 'Failed to send message: $e';
    }
  }

  // Send image message
  Future<String?> sendImage(File imageFile, String chatId) async {
    try {
      print('Starting image upload to Cloudinary...');
      print('Image path: ${imageFile.path}');

      // Check file size (10MB limit)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw ChatException('Image size too large. Maximum size is 10MB');
      }

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          // Use minimal configuration to match preset settings
        ),
      );

      print('Cloudinary upload successful: ${response.secureUrl}');
      await _updateLastMessage(chatId, '📷 Image');
      return response.secureUrl;
    } catch (e) {
      print('Detailed error uploading image: $e');
      throw ChatException('Failed to upload image');
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

  // Simplified upload method
  Future<String?> uploadMedia(File file, MediaType type) async {
    try {
      print('Starting upload to Cloudinary...');
      print('Using preset: chat_preset');
      print('File path: ${file.path}');

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Auto,
          // Remove folder parameter to use preset default
        ),
      );

      print('Upload successful: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Upload error details: $e');
      throw ChatException('Failed to upload media');
    }
  }

  // Enhanced message sending with media support
  Future<void> sendMediaMessage(
    String chatId,
    String senderId,
    String mediaUrl,
    MessageType type,
  ) async {
    try {
      final message = {
        'senderId': senderId,
        'receiverId': chatId.split('_').firstWhere((id) => id != senderId),
        'content': mediaUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type.index,
        'status': MessageStatus.sent.index,
        'isRead': false,
      };

      await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .add(message);

      // Update last message with appropriate icon
      String lastMessage =
          type == MessageType.image ? '📷 Image' : 'Media message';

      await _updateLastMessage(chatId, lastMessage);
    } catch (e) {
      print('Error sending media message: $e');
      throw ChatException('Failed to send media message');
    }
  }
}

// Add this enum
enum MediaType {
  image,
  audio,
  video,
}
