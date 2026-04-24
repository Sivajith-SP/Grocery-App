import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/models/customers_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign up
  Future<User?> signUp(
    String username,
    String email,
    String password,
    String role,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "username": username,
          "email": email,
          "role": role,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Sign up error:$e");
      rethrow;
    }
  }

  //login
  Future<User?> logIn(
    String email,
    String password,
    String selectedRole,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("Log In error");
      return null;
    }
  }

  //get all users
  Stream<List<CustomersModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CustomersModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  //reset password
  Future<dynamic> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Something went wrong";
    }
  }
}
