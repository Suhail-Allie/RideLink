class RideBooking {
  final String customerName;
  final String phoneNumber;
  final String pickupLocation;
  final String destination;
  final String dateTime;
  final String rideType;
  final double distanceKm;
  final double estimatedFare;
  String status;
  String assignedDriver;

  RideBooking({
    required this.customerName,
    required this.phoneNumber,
    required this.pickupLocation,
    required this.destination,
    required this.dateTime,
    required this.rideType,
    required this.distanceKm,
    required this.estimatedFare,
    this.status = 'Pending Driver Assignment',
    this.assignedDriver = 'Not assigned yet',
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'dateTime': dateTime,
      'rideType': rideType,
      'distanceKm': distanceKm,
      'estimatedFare': estimatedFare,
      'status': status,
      'assignedDriver': assignedDriver,
    };
  }

  factory RideBooking.fromJson(Map<String, dynamic> json) {
    return RideBooking(
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      destination: json['destination'] ?? '',
      dateTime: json['dateTime'] ?? '',
      rideType: json['rideType'] ?? 'Book Now',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending Driver Assignment',
      assignedDriver: json['assignedDriver'] ?? 'Not assigned yet',
    );
  }
}