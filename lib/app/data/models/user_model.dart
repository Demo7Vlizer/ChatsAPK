class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime lastSeen;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.lastSeen,
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      lastSeen: DateTime.parse(map['lastSeen']),
      isOnline: map['isOnline'],
    );
  }
} 