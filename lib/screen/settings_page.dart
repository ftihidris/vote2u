import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/toast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  String? _username;
  String? _email;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      String? username = await _authService.getCurrentUserUsername();
      setState(() {
        _username = username ?? 'Username not found';
        _email = _user?.email ?? 'Email not found';
      });
    }
  }

  Future<void> _changePassword() async {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current password to verify your identity.'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                try {
                  await _authService.reauthenticateUser(
                    email: _user!.email!,
                    password: passwordController.text,
                  );
                  await _authService.sendPasswordResetEmail(email: _user!.email!);
                  showToast(message: 'Password reset email sent.');
                } catch (e) {
                  showToast(message: 'Failed to send password reset email: $e');
                }
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current password to verify your identity.'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                try {
                  await _authService.reauthenticateUser(
                    email: _user!.email!,
                    password: passwordController.text,
                  );
                  await _authService.deleteUserAccount();
                  // No need to call signOut again here, it's handled in deleteUserAccount
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showToast(message: 'Failed to delete account: $e');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkPurple,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: largeBorderRadius,
                    ),
                    elevation: elevation2,
                    child: Container(
                      width: double.infinity, // Set the card width to 100% of the screen width
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          const Icon(
                            CupertinoIcons.rectangle_stack_person_crop_fill,
                            size: 170,
                            color: darkPurple,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Student ID',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_username != null)
                            Text(
                              _username!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_email != null)
                            Text(
                              _email!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _changePassword,
                    child: Container(
                      width: double.infinity,
                      height: mediumSizeBox,
                      decoration: BoxDecoration(
                        color: darkPurple,
                        borderRadius: largeBorderRadius,
                      ),
                      child: const Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _deleteAccount,
                    child: Container(
                      width: double.infinity,
                      height: mediumSizeBox,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: largeBorderRadius,
                      ),
                      child: const Center(
                        child: Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
