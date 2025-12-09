import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mm/features/auth/data/models/user_model.dart';
// import 'package:google_sign_in/google_sign_in.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String email, String password, String name);
  // Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource{
  final FirebaseAuth firebaseAuth;
  // final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    // this.googleSignIn,
    required this.firestore,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password, String name) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
    await userCredential.user!.updateDisplayName(name);

    await firestore.collection('users').doc(userCredential.user!.uid).set({
      'userId': userCredential.user!.uid,
      'name':name,
      'email':email,
      'createdAt': FieldValue.serverTimestamp(),
      'authProvider': 'email',
    });
    return UserModel.fromFirebaseUser(userCredential.user!);  
  }

  // @override
  // Future<UserModel> loginWithGoogle() {
  //   // TODO: implement loginWithGoogle
  //   throw UnimplementedError();
  // }

  @override
  Future<void> logout() async{
    await firebaseAuth.signOut();
  } //await googleSignIn.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if(user != null){
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

}