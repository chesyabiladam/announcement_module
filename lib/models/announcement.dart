import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime eventDate;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.eventDate,
  });

  // You can add a factory constructor to convert Firestore data into this model
  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
    );
  }
}
