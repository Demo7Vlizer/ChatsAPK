class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String type; // text, image, audio
  final DateTime timestamp;
  final bool isRead;
  final String? mediaUrl;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'mediaUrl': mediaUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      senderId: map['senderId'],
      content: map['content'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      mediaUrl: map['mediaUrl'],
    );
  }
} 