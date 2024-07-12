import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  // Method to store user's login state using shared preferences
  Future<void> _storeUserLoggedInState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String username, String firstName, String lastName) async {
    try {
      // Check if the email is in the valid student email domain
      if (!email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please enter a valid student email.');
        return null;
      }

      // Check if the username is already taken
      final usernameSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (usernameSnapshot.docs.isNotEmpty) {
        showToast(message: 'Username is already taken.');
        return null;
      }

      // Create user account with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await credential.user!.sendEmailVerification();

      final fcmToken = await _messaging.getToken();

      // Store user information in Firestore users collection
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'fcmtoken': fcmToken,
      });

      // Store login state after successful sign-up
      await _storeUserLoggedInState(true);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing up: $e");
      }
      showToast(message: 'An error occurred. Please try again later.');
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      if (!email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please enter a valid student email.');
        return null;
      }
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await signOut(); // Force logout if email is not verified
        showToast(message: 'Please verify your email.');
        return null;
      }

      await _storeUserLoggedInState(
          true); // Store login state after successful sign-in

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

      // Check if the user's email ends with "@uitm.edu.my"
      if (!googleUser.email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please sign in with a UITM Google account.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _storeUserLoggedInState(
          true); // Store login state after successful Google sign-in
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in with Google: $e");
      }
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
      if (kDebugMode) {
        print("Error signing out: $e");
      }
      showToast(message: 'An error occurred. Please try again later.');
    }
  }

  Future<String?> getCurrentUserUsername() async {
    try {
      // Get current user's ID
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      // Get current user's username from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      // Return the username if the document exists, otherwise return null
      return snapshot.exists ? snapshot.get('username') : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user username: $e');
      }
      return null;
    }
  }

  // Function to delete user account along with their documents
  Future<void> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        showToast(message: 'No user is currently signed in.');
        return;
      }
      // Delete user's document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      // Delete the user account
      await user.delete();
      await FirebaseAuthService().signOut();
      // Clear login state
      await _storeUserLoggedInState(false);

      showToast(message: 'User account deleted successfully.');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user account: $e');
      }
      showToast(message: 'An error occurred while deleting the account.');
    }
  }

  // Function to send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      }
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> reauthenticateUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to reauthenticate user: $e');
    }
  }

  Future<void> initNotifications() async {
  try {
    // Request permissions for iOS
    await _messaging.requestPermission();

    // Get the token for this device
    final fcmToken = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $fcmToken');
    }

    // Optionally, handle token refresh using the instance
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('Token refreshed: $newToken');
      }
      // Handle token refresh as needed
    });

    // Configure background and foreground message handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received a message while in the foreground: ${message.messageId}');
      }
      // Handle your message and show notification with custom behavior
      _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing notifications: $e');
    }
    showToast(message: 'An error occurred while initializing notifications.');
  }
}
// Function to handle incoming messages and show notification with custom behavior
void _showNotification(RemoteMessage message) {
  // Extract notification data
  final notification = message.notification;
  final data = message.data;

  // Customize notification behavior
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    ticker: 'ticker',
    enableVibration: true,
    fullScreenIntent: true,
    styleInformation: DefaultStyleInformation(true, true), // Popup notification
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Display the notification
  flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    notification!.title, // Notification title
    notification.body, // Notification body
    platformChannelSpecifics,
    payload: data['data'], // Optional payload
  );
}
// Inside your `FirebaseAuthService` class
static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('ID: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }
  // Handle your background message logic here
}


}
