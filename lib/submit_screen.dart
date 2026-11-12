import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/carbon_provider.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch() rebuilds this screen whenever a form updates a value.
    final carbon = context.watch<CarbonProvider>();

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
            _co2Card("Transport", carbon.transportCO2),
            _co2Card("Electricity", carbon.electricityCO2),
            _co2Card("Water", carbon.waterCO2),
            _co2Card("Waste", carbon.wasteCO2),
            _co2Card("Food", carbon.foodCO2),

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
                  "Total CO₂: ${carbon.totalCO2.toStringAsFixed(2)} kg",
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
                onPressed: carbon.isSaving
                    ? null
                    : () => _submit(context),
                child: carbon.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(accentBlue),
                        ),
                      )
                    : const Text(
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

  Future<void> _submit(BuildContext context) async {
    final carbon = context.read<CarbonProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await carbon.submitFootprint();
    if (!context.mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text("CO₂ data saved successfully 🌍")),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text("Error saving data: ${carbon.errorMessage}")),
      );
    }
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
