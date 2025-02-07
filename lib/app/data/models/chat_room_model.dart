class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final int unreadCount;
  final DateTime createdAt;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    this.unreadCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'lastMessageSenderId': lastMessageSenderId,
    'unreadCount': unreadCount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) => ChatRoomModel(
    id: map['id'] ?? '',
    participants: List<String>.from(map['participants'] ?? []),
    lastMessage: map['lastMessage'] ?? '',
    lastMessageTime: DateTime.parse(map['lastMessageTime']),
    lastMessageSenderId: map['lastMessageSenderId'] ?? '',
    unreadCount: map['unreadCount'] ?? 0,
    createdAt: DateTime.parse(map['createdAt']),
  );
} 