import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart'; // Import your Announcement model

class AnnouncementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new announcement to Firestore
  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      await _db.collection('announcements').add({
        'title': announcement.title,
        'description': announcement.description,
        'imageUrl': announcement.imageUrl,
        'eventDate': announcement.eventDate,
      });
    } catch (e) {
      print("Error adding announcement: $e");
      throw e;  // You can throw an error to catch it in the UI layer if needed
    }
  }

  // Fetch announcements from Firestore (example)
  Future<List<Announcement>> fetchAnnouncements() async {
    final snapshot = await _db.collection('announcements').get();
    return snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList();
  }
}
