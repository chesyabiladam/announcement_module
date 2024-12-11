import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RegisterUserForm extends StatefulWidget {
  @override
  _RegisterUserFormState createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<RegisterUserForm> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _classController = TextEditingController(); // New field
  final _subjectController = TextEditingController(); // New field

  bool _generatePassword = true; // Toggle for auto password
  String _selectedRole = 'Teacher'; // Default role

  // List of roles to choose from
  List<String> roles = ['Teacher', 'Parent'];

  // Generate random password
  String generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // Check if user exists in Firestore
  Future<DocumentSnapshot?> _getUserDocumentByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('masterUsers')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first; // Return the first matching user
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // Update class and subject for an existing user
  Future<void> _updateUserClassAndSubject(String userId) async {
    try {
      Map<String, dynamic> updatedData = {
        'class': FieldValue.arrayUnion([_classController.text.trim()]),
        'subject': FieldValue.arrayUnion([_subjectController.text.trim()]),
      };

      await _firestore.collection('masterUsers').doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Class and subject added!')));
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  // Register new user or update existing user
  Future<void> _registerOrUpdateUser() async {
    String password = _generatePassword ? generateRandomPassword() : _passwordController.text.trim();

    if (!_generatePassword && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a password or enable password generation.')));
      return;
    }

    try {
      // Check if user already exists
      DocumentSnapshot? userDoc = await _getUserDocumentByEmail(_emailController.text.trim());

      if (userDoc != null) {
        // User exists, so just update their class and subject
        await _updateUserClassAndSubject(userDoc.id);
      } else {
        // User doesn't exist, create new user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: password,
        );

        Map<String, dynamic> userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
        };

        if (_selectedRole == 'Teacher') {
          userData['class'] = [_classController.text.trim()];
          userData['subject'] = [_subjectController.text.trim()];
        }

        await _firestore.collection('masterUsers').doc(userCredential.user?.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User registered! Password: $password')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register or Update User')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Dropdown to select user role
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: roles.map<DropdownMenuItem<String>>((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
            ),

            // Conditional fields for "Teacher" role
            if (_selectedRole == 'Teacher') ...[
              TextField(
                controller: _classController,
                decoration: InputDecoration(labelText: 'Class'),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
            ],

            SizedBox(height: 20),

            Row(
              children: [
                Checkbox(
                  value: _generatePassword,
                  onChanged: (bool? value) {
                    setState(() {
                      _generatePassword = value!;
                      if (_generatePassword) {
                        _passwordController.clear();
                      }
                    });
                  },
                ),
                Text('Generate Password Automatically'),
              ],
            ),

            if (!_generatePassword)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerOrUpdateUser,
              child: Text('Register or Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
