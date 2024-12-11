import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_login_page.dart';
import 'screens/admin_login_page.dart';
import 'screens/parent_teacher_login_page.dart'; // Page for parent/teacher login
import 'screens/admin_dashboard.dart'; // Placeholder for Admin Dashboard
import 'screens/parent_dashboard.dart'; // Placeholder for Parent Dashboard
import 'screens/teacher_dashboard.dart'; // Placeholder for Teacher Dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMSS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Initial route and routing configuration
      initialRoute: '/',
      routes: {
        '/': (context) => MainLoginPage(), // Main login screen (Parent/Teacher options)
        '/parent_teacher_login': (context) => ParentTeacherLoginPage(role: 'Parent'), // Parent login page
        '/admin_login': (context) => AdminLoginPage(), // Admin login page
        '/admin_dashboard': (context) => AdminDashboard(), // Admin Dashboard screen (Create this screen)
        '/parent_dashboard': (context) => ParentDashboard(), // Parent Dashboard screen (Create this screen)
        '/teacher_dashboard': (context) => TeacherDashboard(), // Teacher Dashboard screen (Create this screen)
      },
    );
  }
}
