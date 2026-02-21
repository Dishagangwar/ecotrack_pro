import 'package:flutter/material.dart';
import '../services/carbon_tracker.dart';
import '../services/firebase_service.dart';
import '../models/carbon_footprint.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = CarbonTracker();

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Submit CO₂ Data"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cards for each form emission
            _co2Card("Transport", tracker.transportCO2),
            _co2Card("Electricity", tracker.electricityCO2),
            _co2Card("Water", tracker.waterCO2),
            _co2Card("Waste", tracker.wasteCO2),
            _co2Card("Food", tracker.foodCO2),

            const SizedBox(height: 30),

            // Total CO2
            Card(
              color: cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: accentBlue),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total CO₂: ${tracker.totalCO2.toStringAsFixed(2)} kg",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
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
                ),
                onPressed: () async {
                  try {
                    final footprint = CarbonFootprint(
                      transportCO2: tracker.transportCO2,
                      electricityCO2: tracker.electricityCO2,
                      waterCO2: tracker.waterCO2,
                      wasteCO2: tracker.wasteCO2,
                      foodCO2: tracker.foodCO2,
                    );

                    await FirebaseService().saveCarbonFootprint(footprint);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("CO₂ data saved successfully 🌍"),
                      ),
                    );

                    tracker.reset();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving data: $e")),
                    );
                  }
                },

                child: const Text(
                  "💾 Submit All CO₂ Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable card widget for each CO2 value
  Widget _co2Card(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: accentBlue),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$label CO₂",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${value.toStringAsFixed(2)} kg",
                style: const TextStyle(
                  color: accentBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
