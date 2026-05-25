class DriverProfile {
  final String name;
  final String phoneNumber;
  final String vehicle;
  final String password;

  DriverProfile({
    required this.name,
    required this.phoneNumber,
    required this.vehicle,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'vehicle': vehicle,
      'password': password,
    };
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      vehicle: json['vehicle'] ?? '',
      password: json['password'] ?? '',
    );
  }
}