class CarbonFootprint {
  double transportCO2;
  double electricityCO2;
  double waterCO2;
  double wasteCO2;
  double foodCO2;
  DateTime timestamp;

  CarbonFootprint({
    required this.transportCO2,
    required this.electricityCO2,
    required this.waterCO2,
    required this.wasteCO2,
    required this.foodCO2,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'transportCO2': transportCO2,
      'electricityCO2': electricityCO2,
      'waterCO2': waterCO2,
      'wasteCO2': wasteCO2,
      'foodCO2': foodCO2,
      'totalCO2': totalCO2,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CarbonFootprint.fromMap(Map<String, dynamic> map) {
    return CarbonFootprint(
      transportCO2: map['transportCO2']?.toDouble() ?? 0.0,
      electricityCO2: map['electricityCO2']?.toDouble() ?? 0.0,
      waterCO2: map['waterCO2']?.toDouble() ?? 0.0,
      wasteCO2: map['wasteCO2']?.toDouble() ?? 0.0,
      foodCO2: map['foodCO2']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  double get totalCO2 =>
      transportCO2 + electricityCO2 + waterCO2 + wasteCO2 + foodCO2;
}
