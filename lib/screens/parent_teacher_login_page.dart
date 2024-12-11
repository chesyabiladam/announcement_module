import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentTeacherLoginPage extends StatefulWidget {
  final String role; // Role passed through constructor (Parent or Teacher)

  ParentTeacherLoginPage({required this.role});

  @override
  _ParentTeacherLoginPageState createState() => _ParentTeacherLoginPageState();
}

class _ParentTeacherLoginPageState extends State<ParentTeacherLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    try {
      // Sign in the user using email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Get the user data from Firestore
        final userDoc = await _firestore
            .collection('masterUsers')
            .doc(userCredential.user?.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          String role = userData?['role']; // Retrieve the role from Firestore

          // Navigate to the appropriate dashboard based on the role
          if (role == 'Parent') {
            Navigator.pushNamed(context, '/parent_dashboard'); // Navigate to Parent Dashboard
          } else if (role == 'Teacher') {
            Navigator.pushNamed(context, '/teacher_dashboard'); // Navigate to Teacher Dashboard
          } else {
            // Handle if the role is not 'Parent' or 'Teacher'
            print('Invalid role');
          }
        } else {
          print('User data not found');
        }
      }
    } catch (e) {
      print('Login failed: $e');
      // You can show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login as ${widget.role}'),
            ),
          ],
        ),
      ),
    );
  }
}
