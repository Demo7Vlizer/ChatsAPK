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
      'timestamp': FieldValue.serverTimestamp(),
      'type': type.index,
      'status': status.index,
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    print('Parsing message: $map');
    
    dynamic timestamp = map['timestamp'];
    DateTime messageTime;
    
    if (timestamp is Timestamp) {
      messageTime = timestamp.toDate();
    } else if (timestamp is int) {
      messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      messageTime = DateTime.now();
    }

    return MessageModel(
      id: id,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: messageTime,
      type: MessageType.values[map['type'] is int ? map['type'] : 0],
      status: MessageStatus.values[map['status'] is int ? map['status'] : 0],
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