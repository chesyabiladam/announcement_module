import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/announcement.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';
import 'announcements_screen.dart';
import 'profile_screen_teacher.dart';  // Import the teacher profile screen

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  late Stream<List<Announcement>> _announcementStream;

  @override
  void initState() {
    super.initState();
    _announcementStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar() {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = 'Dashboard';
        break;
      case 1:
        title = 'Announcements';
        break;
      case 2:
        title = 'Profile Detail';
        break;
      default:
        title = 'Dashboard';
    }

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey[200], // Set the background color to grey
      body: _selectedIndex == 0
          ? StreamBuilder<List<Announcement>>(
        stream: _announcementStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final announcements = snapshot.data ?? [];

          return Column(
            children: [
              SizedBox(height: 8),
              // Align ANNOUNCEMENT text to the left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align left
                  children: [
                    Text(
                      'ANNOUNCEMENT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10), // Space between text and carousel
              CarouselSlider.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index, realIndex) {
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
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(announcement.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 3 / 2,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlayInterval: Duration(seconds: 3),
                ),
              ),
            ],
          );
        },
      )
          : _selectedIndex == 1
          ? AnnouncementsScreen()
          : ProfileScreenTeacher(), // Change ProfileScreen to ProfileScreenTeacher
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Announcement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
