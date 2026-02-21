import 'package:ecotrack_pro/services/carbon_tracker.dart';
import 'package:flutter/material.dart';
import 'transport_form.dart';
import 'co2_calculator.dart';

class FoodForm extends StatefulWidget {
  const FoodForm({super.key});

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  String selectedDiet = 'Vegan';
  String outsideFood = 'No';
  double co2Emission = 0.0;

  void _calculateAndSave() {
    setState(() {
      co2Emission = calculateFoodCO2(
        dietType: selectedDiet,
        outsideFood: outsideFood == 'Yes',
      );
    });
    CarbonTracker().foodCO2 = co2Emission;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _baseScaffold(
      title: "Food Habits 🍎",
      child: Column(
        children: [
          _dropdown(
            label: "Diet Type",
            items: ["Vegan", "Vegetarian", "Mixed", "Heavy Meat"],
            value: selectedDiet,
            onChanged: (value) => setState(() => selectedDiet = value),
          ),
          _dropdown(
            label: "Outside Food?",
            items: ["Yes", "No"],
            value: outsideFood,
            onChanged: (value) => setState(() => outsideFood = value),
          ),
          _saveButton(),
          if (co2Emission > 0) ...[
            const SizedBox(height: 20),
            Text(
              "Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _baseScaffold({required String title, required Widget child}) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _dropdown({
    required String label,
    required List<String> items,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        dropdownColor: cardDark,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (_) {},
        decoration: InputDecoration(
          filled: true,
          fillColor: cardDark,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
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
        onPressed: _calculateAndSave,
        child: const Text(
          "💾 Save",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
