import 'package:provider/provider.dart';
import 'package:ecotrack_pro/providers/carbon_provider.dart';
import 'package:flutter/material.dart';
import 'transport_form.dart';
import 'co2_calculator.dart';

class WasteForm extends StatefulWidget {
  const WasteForm({super.key});

  @override
  State<WasteForm> createState() => _WasteFormState();
}

class _WasteFormState extends State<WasteForm> {
  String selectedWaste = 'Low';
  String recycledToday = 'No';
  double co2Emission = 0.0;

  void _calculateAndSave() {
    setState(() {
      co2Emission = calculateWasteCO2(
        wasteLevel: selectedWaste,
        isRecycled: recycledToday == 'Yes',
      );
    });
    context.read<CarbonProvider>().wasteCO2 = co2Emission;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _baseScaffold(
      title: "Waste & Recycling ♻️",
      child: Column(
        children: [
          _dropdown(
            "Waste Generated",
            ["Low", "Medium", "High"],
            selectedWaste,
            (value) => setState(() => selectedWaste = value),
          ),
          _dropdown(
            "Recycled Today?",
            ["Yes", "No"],
            recycledToday,
            (value) => setState(() => recycledToday = value),
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

  Widget _dropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
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
