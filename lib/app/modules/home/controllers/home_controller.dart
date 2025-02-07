import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my/app/routes/app_pages.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final searchController = TextEditingController();
  final RxString userName = ''.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.displayName ?? 'User';
      loadUsers();
      _setupSearchListener();
    }
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredUsers.value = users;
      } else {
        filteredUsers.value = users.where((user) => 
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  void loadUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      users.value = snapshot.docs
          .map((doc) => UserModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((user) => user.id != _authService.currentUser.value?.uid)
          .toList();
      filteredUsers.value = users;
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void startChat(String userId, String userName, String userPhoto) {
    print('Starting chat with:');
    print('UserID: $userId');
    print('UserName: $userName');
    print('UserPhoto: $userPhoto');
    
    Get.toNamed(
      Routes.CHAT, 
      arguments: {
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
      }
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> signOut() async {
    final currentUserId = _authService.currentUser.value!.uid;
    // Update user status before signing out
    await _firestore.collection('users').doc(currentUserId).update({
      'lastSeen': DateTime.now().toIso8601String(),
      'isOnline': false,
    });
    await _authService.signOut();
    Get.offAllNamed('/onboarding');
  }
} 