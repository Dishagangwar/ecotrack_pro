// ignore: file_names
const Map<String, double> emissionFactors = {
  'Walking': 0.0,
  'Bicycle': 0.0,
  'Train': 0.041,
  'Flight': 0.255,
};

// Fuel-specific emission factors (kg CO2 per km)
const Map<String, double> fuelFactors = {
  'Petrol': 0.192,
  'Diesel': 0.171,
  'Electric': 0.05,
};

// CO2 calculation function
double calculateCO2({
  required double distanceKm,
  required String transportMode,
  String? fuelType,
}) {
  double factor = 0.0;

  if (transportMode == 'Car' || transportMode == 'Bus') {
    factor = fuelFactors[fuelType ?? 'Petrol'] ?? 0.0;
  } else {
    factor = emissionFactors[transportMode] ?? 0.0;
  }

  return distanceKm * factor;
}

// Electricity CO2 calculation function
const double electricityEmissionFactor = 0.82; // kg CO2 per kWh (India avg)
const Map<String, double> applianceWeight = {
  'AC': 1.2,
  'Heater': 1.3,
  'Washing Machine': 1.0,
  'Laptop': 0.8,
  'TV': 0.9,
};
double calculateElectricityCO2({
  required double unitsKwh,
  required String appliance,
}) {
  final multiplier = applianceWeight[appliance] ?? 1.0;
  return unitsKwh * electricityEmissionFactor * multiplier;
}

// Water CO2 calculation function
const double co2PerLiterWater = 0.00034; // kg CO2 per liter
const double showerLitersPerMinute = 9.0;
const double laundryLitersPerLoad = 50.0;

double calculateWaterCO2({
  required double showerMinutes,
  required double laundryLoads,
}) {
  final showerCO2 = showerMinutes * showerLitersPerMinute * co2PerLiterWater;
  final laundryCO2 = laundryLoads * laundryLitersPerLoad * co2PerLiterWater;

  return showerCO2 + laundryCO2;
}

//  Waste CO2 calculation function
const Map<String, double> wasteEmission = {
  'Low': 0.5,
  'Medium': 1.0,
  'High': 2.0,
};
double calculateWasteCO2({
  required String wasteLevel,
  required bool isRecycled,
}) {
  final baseCO2 = wasteEmission[wasteLevel] ?? 0.0;
  return isRecycled ? baseCO2 * 0.6 : baseCO2;
}

// Food CO2 calculation function
const Map<String, double> dietEmission = {
  'Vegan': 1.5,
  'Vegetarian': 2.0,
  'Mixed': 3.5,
  'Heavy Meat': 5.0,
};
double calculateFoodCO2({required String dietType, required bool outsideFood}) {
  final baseCO2 = dietEmission[dietType] ?? 0.0;
  return outsideFood ? baseCO2 * 1.2 : baseCO2;
}
double calculateEcoScore(double totalCO2) {
  const double maxCO2 = 5.0; // max safe daily CO₂ (kg)

  double score = 100 - (totalCO2 / maxCO2) * 100;

  // Clamp between 0 and 100
  return score.clamp(0, 100);
}

