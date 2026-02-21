
import 'package:ecotrack_pro/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications FIRST
  await LocalNotificationService.init();
    await LocalNotificationService.scheduleAt(hour: 11,
    minute: 25, title: "notification", body: "detail of notification");

  // Firebase init
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyD7ErqTIJukdxY31QzOBbXq8Fq2uxFAXyM",
        authDomain: "ecotrack-pro-32cdd.firebaseapp.com",
        projectId: "ecotrack-pro-32cdd",
        storageBucket: "ecotrack-pro-32cdd.firebasestorage.app",
        messagingSenderId: "550065944544",
        appId: "1:550065944544:web:506faa5790e4b2f3b05d85",
        measurementId: "G-CFNYXDZ4SB",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const EcoTrackApp());

  // 🔥 TEMPORARY TEST — REMOVE AFTER CONFIRMATION
  // await LocalNotificationService.showNow(
  //   title: "🌱 EcoTrack",
  //   body: "Notifications are working!",
  // );
}


class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Dark theme to match EcoTrack UI
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050B14),
        fontFamily: 'Roboto',
      ),

      // Initial screen
      home: const AuthWrapper(),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User already logged in
          return const DashboardScreen();
        } else {
          // User not logged in
          return const LoginScreen();
        }
      },
    );
  }
}

