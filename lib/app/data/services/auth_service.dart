import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable user state
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    currentUser.bindStream(_auth.authStateChanges());
    ever(currentUser, _handleUserStatus);
    super.onInit();
  }

  void _handleUserStatus(User? user) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': true,
        'lastSeen': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      // Save user data to Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    
    // Check if user exists
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      // Create new user document
      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastSeen': DateTime.now().toIso8601String(),
        'isOnline': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      // Update existing user
      await userRef.update({
        'lastSeen': DateTime.now().toIso8601String(),
        'isOnline': true,
      });
    }
  }

  Future<void> signOut() async {
    if (currentUser.value != null) {
      await _firestore.collection('users').doc(currentUser.value!.uid).update({
        'isOnline': false,
        'lastSeen': DateTime.now().toIso8601String(),
      });
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
} 