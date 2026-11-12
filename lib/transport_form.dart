import 'package:flutter/material.dart';
import 'co2_calculator.dart';
import 'package:provider/provider.dart';
import 'providers/carbon_provider.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class TransportForm extends StatefulWidget {
  const TransportForm({super.key});

  @override
  State<TransportForm> createState() => _TransportFormState();
}

class _TransportFormState extends State<TransportForm> {
  final TextEditingController _distanceController = TextEditingController();
  String selectedMode = 'Walking';
  String selectedFuel = 'Petrol';
  double co2Emission = 0.0;

  void _calculateAndSave() {
    final distance = double.tryParse(_distanceController.text) ?? 0.0;

    setState(() {
      co2Emission = calculateCO2(
        distanceKm: distance,
        transportMode: selectedMode,
        fuelType: selectedFuel,
      );
    });
    context.read<CarbonProvider>().transportCO2 = co2Emission;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _baseScaffold(
      title: "Transportation 🚗",
      child: Column(
        children: [
          _input("Distance traveled (km)"),
          _dropdown(
            "Transport Mode",
            ["Walking", "Bicycle", "Bus", "Car", "Train", "Flight"],
            selectedMode,
            (value) => setState(() => selectedMode = value),
          ),
          // Show fuel dropdown only if mode is Car or Bus
          if (selectedMode == 'Car' || selectedMode == 'Bus')
            _dropdown(
              "Fuel Type",
              fuelFactors.keys.toList(),
              selectedFuel,
              (value) => setState(() => selectedFuel = value),
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

  Widget _input(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _distanceController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: cardDark,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String selectedValue,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        dropdownColor: cardDark,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => onChanged(value!),
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
