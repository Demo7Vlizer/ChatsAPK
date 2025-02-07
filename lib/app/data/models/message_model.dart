import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isDeleted;
  
  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString(),
      'status': status.toString(),
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    print('Parsing message: $map');
    return MessageModel(
      id: id,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] ?? '',
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: MessageType.values[map['type'] as int],
      status: MessageStatus.values[map['status'] as int],
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}

enum MessageType {
  text,
  image,
  voice,
  file
}

enum MessageStatus {
  sent,
  delivered,
  read
} 