import 'package:ecotrack_pro/food_form.dart';
import 'package:ecotrack_pro/submit_screen.dart';
import 'package:ecotrack_pro/waste_form.dart';
import 'package:ecotrack_pro/water_form.dart';
import 'package:flutter/material.dart';
import 'transport_form.dart';
import 'electricity_form.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class TrackDailyHabitsScreen extends StatelessWidget {
  const TrackDailyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Track Daily Habits",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071A2D), Color(0xFF050B14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Log your eco activities for today 🌱",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 24),

              _habitCard(
                icon: "🚗",
                title: "Transportation",
                subtitle: "Travel distance & vehicle type",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransportForm()),
                  );
                },
              ),

              _habitCard(
                icon: "⚡",
                title: "Electricity Usage",
                subtitle: "Appliances & power consumption",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ElectricityForm()),
                  );
                },
              ),

              _habitCard(
                icon: "💧",
                title: "Water Usage",
                subtitle: "Shower, laundry & daily use",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WaterForm()),
                  );
                },
              ),

              _habitCard(
                icon: "🍎",
                title: "Food Habits",
                subtitle: "Diet & food choices",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoodForm()),
                  );
                },
              ),

              _habitCard(
                icon: "♻️",
                title: "Waste & Recycling",
                subtitle: "Plastic & recycling activity",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WasteForm()),
                  );
                },
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
                    shadowColor: accentBlue.withOpacity(0.4),
                    elevation: 6,
                  ),
                  onPressed: () {
                    // Save daily habits
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubmitScreen()),
                  );
                  },
                  child: const Text(
                    "✅ Save Today’s Data",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _habitCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentBlue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: accentBlue.withOpacity(0.15), blurRadius: 15),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
