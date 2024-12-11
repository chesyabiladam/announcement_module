import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainLoginPage extends StatefulWidget {
  @override
  _MainLoginPageState createState() => _MainLoginPageState();
}

class _MainLoginPageState extends State<MainLoginPage> {
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid role or missing role')),
            );
          }
        } else {
          print('User data not found');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data not found')),
          );
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
      appBar: null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Full-width image at the top, taking up 1/5 of the screen height
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://img.freepik.com/premium-photo/school-books-color-pencil-pen-desk-can-creative-infographics-blackboard-inside_488220-429.jpg?w=360'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 60), // Spacing between the image and text
          // Padding around the text and buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Log In" title
                Text(
                  'Log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                // Subtext
                Text(
                  'Sign In to access your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 50),
                // Email and Password input fields
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
                // Sign In button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text('Sign in'),
                ),
                SizedBox(height: 30),
                // Admin Login clickable text
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/admin_login');
                  },
                  child: Text(
                    'Admin Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
