import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      username = doc['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071A2D), Color(0xFF050B14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: username.isEmpty
                          ? "Welcome "
                          : "Welcome, $username ",
                    ),
                    const TextSpan(text: "👋"),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Ready to start your green journey?",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentBlue.withOpacity(0.25),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card title
                    Row(
                      children: const [
                        Text("🌍", style: TextStyle(fontSize: 22)),
                        SizedBox(width: 10),
                        Text(
                          "How EcoTrack Helps You",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "We make sustainability simple. Instead of guessing, use our AI tools to measure your impact on the planet.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _bullet(
                      icon: "📊",
                      title: "Track Daily Habits",
                      text:
                          "Enter your travel or electricity usage in the Dashboard to calculate your Carbon Footprint.",
                    ),

                    _bullet(
                      icon: "🍎",
                      title: "Scan & Check",
                      text:
                          "Use Vision AI to snap photos of appliances or food to instantly see their eco-rating.",
                    ),

                    _bullet(
                      icon: "💡",
                      title: "Get Advice",
                      text:
                          "Our system gives you personalized tips to save energy and money.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: accentBlue),
                    ),
                    elevation: 6,
                    shadowColor: accentBlue.withOpacity(0.4),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    "🚀 Go to Dashboard",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet({
    required String icon,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
