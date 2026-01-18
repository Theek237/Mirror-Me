import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<AuthUserModel?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(fullName);

    final uid = credential.user?.uid;
    if (uid != null) {
      _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
        'photoUrl': credential.user?.photoURL,
      }, SetOptions(merge: true));
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _upsertUser(userCredential.user);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> _upsertUser(User? user) async {
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'fullName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastSignInAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  AuthUserModel? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }
}
