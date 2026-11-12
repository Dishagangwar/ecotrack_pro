import 'package:flutter/material.dart';
import 'co2_calculator.dart';
import 'package:provider/provider.dart';
import 'providers/carbon_provider.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);

class ElectricityForm extends StatefulWidget {
  const ElectricityForm({super.key});

  @override
  State<ElectricityForm> createState() => _ElectricityFormState();
}

class _ElectricityFormState extends State<ElectricityForm> {
  final TextEditingController _unitsController = TextEditingController();

  String selectedAppliance = 'AC';
  double co2Emission = 0.0;

  void _calculateAndSave() {
    final units = double.tryParse(_unitsController.text) ?? 0.0;

    setState(() {
      co2Emission = calculateElectricityCO2(
        unitsKwh: units,
        appliance: selectedAppliance,
      );
    });
    context.read<CarbonProvider>().electricityCO2 = co2Emission;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _baseScaffold(
      title: "Electricity Usage ⚡",
      child: Column(
        children: [
          _input("Units Consumed (kWh)"),
          _dropdown("Primary Usage", [
            "AC",
            "Heater",
            "Washing Machine",
            "Laptop",
            "TV",
          ]),
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
        controller: _unitsController,
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

  Widget _dropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: selectedAppliance,
        dropdownColor: cardDark,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedAppliance = value!;
          });
        },
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
