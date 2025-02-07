class ChatRoomModel {
  final String id;
  final List<String> participants;
  final DateTime lastMessageTime;
  final String lastMessage;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'],
      participants: List<String>.from(map['participants']),
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      lastMessage: map['lastMessage'],
    );
  }
} 