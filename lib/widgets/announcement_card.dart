import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the image at the top
          if (announcement.imageUrl.isNotEmpty)
            Image.network(
              announcement.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              // Error handling for image load issues
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                height: 200,
                width: double.infinity,
                child: Icon(Icons.broken_image, color: Colors.grey[600]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  announcement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'Event Date: ${announcement.eventDate != null ? "${announcement.eventDate.day}/${announcement.eventDate.month}/${announcement.eventDate.year}" : "No Date"}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
