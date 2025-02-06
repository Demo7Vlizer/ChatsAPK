import 'package:get/get.dart';

class AuthService extends GetxService {
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Simulate checking stored credentials
    checkLoginStatus();
  }

  void checkLoginStatus() {
    // Simulate checking stored credentials
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login
      currentUser.value = UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: 'https://via.placeholder.com/150',
      );
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  bool get isSignedIn => isLoggedIn.value;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });
} 