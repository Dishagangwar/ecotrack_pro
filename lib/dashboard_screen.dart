import 'package:ecotrack_pro/chatbot_screen.dart';
import 'package:ecotrack_pro/co2_calculator.dart';
import 'package:ecotrack_pro/scan_screen.dart';
import 'package:ecotrack_pro/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'track_daily_habits_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    LocalNotificationService.showNow(
      title: "🌱 EcoTrack",
      body: "Notifications are working!",
    );

     final now = DateTime.now().add(const Duration(minutes: 2));

  LocalNotificationService.scheduleAt(
    hour: now.hour,
    minute: now.minute,
    title: "⏰ Eco Reminder",
    body: "Scheduled notification test",
  );
  }

  Stream<double> totalCO2Stream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('carbonFootprints')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return 0.0;
          return (snapshot.data()!['totalCO2'] ?? 0.0).toDouble();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071A2D), Color(0xFF050B14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Sustainability Overview 🌱",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Stats cards
              Row(
                children: [
                  StreamBuilder<double>(
                    stream: totalCO2Stream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _statCard(
                          title: "Carbon Footprint",
                          value: "--",
                          unit: "kg",
                          icon: "🌍",
                        );
                      }

                      final totalCO2 = snapshot.data ?? 0.0;

                      return _statCard(
                        title: "Carbon Footprint",
                        value: totalCO2.toStringAsFixed(2),
                        unit: "kg",
                        icon: "🌍",
                      );
                    },
                  ),

                  StreamBuilder<double>(
                    stream: totalCO2Stream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _statCard(
                          title: "Eco Score",
                          value: "--",
                          unit: "%",
                          icon: "💚",
                        );
                      }

                      final totalCO2 = snapshot.data ?? 0.0;
                      final ecoScore = calculateEcoScore(totalCO2);

                      return _statCard(
                        title: "Eco Score",
                        value: ecoScore.toStringAsFixed(0),
                        unit: "%",
                        icon: "💚",
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrackDailyHabitsScreen(),
                    ),
                  );
                },
                child: _actionTile(
                  icon: "📊",
                  title: "Track Daily Habits",
                  subtitle: "Log travel & electricity usage",
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanCheckScreen(),
                    ),
                  );
                },
                child: _actionTile(
                  icon: "📷",
                  title: "Scan & Check",
                  subtitle: "Scan appliances or food items",
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EcoBotChatScreen(),
                    ),
                  );
                },

                child: _actionTile(
                  icon: "💡",
                  title: "Get AI Advice",
                  subtitle: "Personalized eco-friendly tips",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String unit,
    required String icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: accentBlue.withOpacity(0.25), blurRadius: 20),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: " $unit",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentBlue.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> checkDailyCarbon() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('carbonFootprints')
        .doc(uid)
        .get();

    // Schedule time → 9:00 PM
    const hour = 11;
    const minute = 40;

    if (!doc.exists) {
      LocalNotificationService.scheduleAt(
        hour: hour,
        minute: minute,
        title: "🌱 EcoTrack Reminder",
        body: "Don't forget to log today's carbon usage!",
      );
      return;
    }

    final lastUpdated = (doc.data()!['lastUpdated'] as Timestamp?)?.toDate();

    final today = DateTime.now();

    final isToday =
        lastUpdated != null &&
        lastUpdated.year == today.year &&
        lastUpdated.month == today.month &&
        lastUpdated.day == today.day;

    if (!isToday) {
      LocalNotificationService.scheduleAt(
        hour: hour,
        minute: minute,
        title: "🌱 EcoTrack Reminder",
        body: "You haven't logged today's carbon data yet.",
      );
    } else {
      final totalCO2 = doc['totalCO2'] ?? 0.0;
      LocalNotificationService.scheduleAt(
        hour: hour,
        minute: minute,
        title: "🌍 Daily Carbon Summary",
        body: "Your carbon footprint today is $totalCO2 kg CO₂",
      );
    }
  }
}
