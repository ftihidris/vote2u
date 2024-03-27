import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String studentEmailDomain = "@student.uitm.edu.my";


  // Method to store user's login state using shared preferences
  Future<void> _storeUserLoggedInState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Method to retrieve user's login state from shared preferences
  Future<bool> _getUserLoggedInState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password, String username, String firstName, String lastName) async {
    try {
      if (!email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please enter a valid student email.');
        return null;
      }
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
      });
      await _storeUserLoggedInState(true); // Store login state after successful sign-up
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred. Please try again later.');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (!email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please enter a valid student email.');
        return null;
      }
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storeUserLoggedInState(true); // Store login state after successful sign-in
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: 'An error occurred. Please try again later.');
      }
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _storeUserLoggedInState(true); // Store login state after successful Google sign-in
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      showToast(message: 'An error occurred. Please try again later.');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _storeUserLoggedInState(false); // Clear login state after sign-out
    } catch (e) {
      print("Error signing out: $e");
      showToast(message: 'An error occurred. Please try again later.');
    }
  }
}
