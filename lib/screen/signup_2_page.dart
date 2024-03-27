import 'package:flutter/material.dart';

class SignUpPageStep2 extends StatelessWidget {
  final Function(String, String) onSignUp;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const SignUpPageStep2({
    Key? key,
    required this.onSignUp,
    required this.firstNameController,
    required this.lastNameController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up (Step 2 of 2)'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                onSignUp(firstName, lastName); // Callback to execute sign-up
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
