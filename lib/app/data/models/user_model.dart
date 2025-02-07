class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime lastSeen;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.lastSeen,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      lastSeen: DateTime.parse(map['lastSeen']),
      isOnline: map['isOnline'],
    );
  }
} 