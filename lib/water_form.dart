import 'package:flutter/material.dart';
import 'transport_form.dart';
import 'co2_calculator.dart';
import 'package:provider/provider.dart';
import 'providers/carbon_provider.dart';
class WaterForm extends StatefulWidget {
  const WaterForm({super.key});

  @override
  State<WaterForm> createState() => _WaterFormState();
}

class _WaterFormState extends State<WaterForm> {
  final TextEditingController _showerController = TextEditingController();
  final TextEditingController _laundryController = TextEditingController();

  double co2Emission = 0.0;

  void _calculateAndSave() {
    final showerMinutes =
        double.tryParse(_showerController.text) ?? 0.0;
    final laundryLoads =
        double.tryParse(_laundryController.text) ?? 0.0;

    setState(() {
      co2Emission = calculateWaterCO2(
        showerMinutes: showerMinutes,
        laundryLoads: laundryLoads,
      );
    });
    context.read<CarbonProvider>().waterCO2 = co2Emission;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Estimated CO₂: ${co2Emission.toStringAsFixed(2)} kg",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _baseScaffold(
      title: "Water Usage 💧",
      child: Column(
        children: [
          _input("Shower Time (minutes)", _showerController),
          _input("Laundry Loads", _laundryController),
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
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: child,
    ),
  );
}

Widget _input(String hint,TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller, 
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
