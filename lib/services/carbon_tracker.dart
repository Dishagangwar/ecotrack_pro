class CarbonTracker {
  // Singleton pattern
  static final CarbonTracker _instance = CarbonTracker._internal();
  factory CarbonTracker() => _instance;
  CarbonTracker._internal();

  // CO2 values from all forms
  double transportCO2 = 0.0;
  double electricityCO2 = 0.0;
  double waterCO2 = 0.0;
  double wasteCO2 = 0.0;
  double foodCO2 = 0.0;

  // Helper: total CO2
  double get totalCO2 =>
      transportCO2 + electricityCO2 + waterCO2 + wasteCO2 + foodCO2;

  // Optional: reset values
  void reset() {
    transportCO2 = 0.0;
    electricityCO2 = 0.0;
    waterCO2 = 0.0;
    wasteCO2 = 0.0;
    foodCO2 = 0.0;
  }
}
