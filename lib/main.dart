
import 'package:ecotrack_pro/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/carbon_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load API keys from .env (not committed to git)
  await dotenv.load(fileName: ".env");

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
}


class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // All shared state lives here, above MaterialApp, so every screen
    // can reach it without passing objects through constructors.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // These two depend on who is signed in, so they re-bind
        // automatically whenever AuthProvider reports a new user.
        ChangeNotifierProxyProvider<AuthProvider, CarbonProvider>(
          create: (_) => CarbonProvider(),
          update: (_, auth, carbon) => carbon!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, user) => user!..bindUser(auth.uid),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // Dark theme to match EcoTrack UI
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050B14),
          fontFamily: 'Roboto',
        ),

        // Initial screen
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
