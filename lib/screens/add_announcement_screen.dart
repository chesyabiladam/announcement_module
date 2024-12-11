import 'package:flutter/material.dart';
import '../models/announcement.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // Image Picker package
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage

class AddAnnouncementScreen extends StatefulWidget {
  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String imageUrl = '';
  DateTime? selectedDate;

  // Method to submit announcement to Firebase
  void _submitAnnouncement() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      // Create a new Announcement object
      final newAnnouncement = Announcement(
        id: DateTime.now().toString(),  // Optional: Auto-generate an ID
        title: title,
        description: description,
        imageUrl: imageUrl,
        eventDate: selectedDate!,
      );

      // Save the announcement to Firestore
      try {
        await FirebaseFirestore.instance.collection('announcements').add({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'eventDate': selectedDate,
          'createdAt': Timestamp.now(),
        });

        // Debug: Print a confirmation that the data has been added
        print("Announcement added to Firestore");

        // After adding to Firestore, show confirmation and pop screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement added successfully!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add announcement')));
      }
    } else if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a date')));
    }
  }

  // Method to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Debug: Print the selected date
      print("Selected Date: ${selectedDate.toString()}");
    }
  }

  // Reusable input field builder
  Widget buildInputField(String label, Function(String) onChanged, {int minLines = 1, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, // Remove default border
          contentPadding: EdgeInsets.all(16), // Add some padding inside
        ),
        minLines: minLines,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a $label';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set to match the Announcements screen background
      appBar: AppBar(
        title: Text('Add Announcement'),
        backgroundColor: Colors.white, // Set the AppBar color
        foregroundColor: Colors.black, // Set the text color to black
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInputField('Title', (value) => title = value),
              SizedBox(height: 10), // Space between fields
              buildInputField('Description', (value) => description = value, minLines: 3, maxLines: 9),
              SizedBox(height: 10), // Space between fields
              buildInputField('Image URL', (value) => imageUrl = value),
              SizedBox(height: 20),

              // Row for Event Date and Select Date button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Event Date: ${selectedDate != null ? DateFormat.yMMMMd().format(selectedDate!) : 'Not selected'}',
                    ),
                  ),
                  SizedBox(width: 10), // Space between text and button
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30), // Space before Add Announcement button

              // Centered Add Announcement Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitAnnouncement,
                  child: Text('Add Announcement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
