import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  late Stream<List<Announcement>> _announcementStream;

  AnnouncementsScreen({Key? key}) : super(key: key) {
    _announcementStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('eventDate', descending: true) // Sort by date, most recent first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Announcement.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<List<Announcement>>(
        stream: _announcementStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final announcements = snapshot.data ?? [];

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailScreen(announcement: announcement),
                    ),
                  );
                },
                child: AnnouncementCard(announcement: announcement),
              );
            },
          );
        },
      ),
    );
  }
}
