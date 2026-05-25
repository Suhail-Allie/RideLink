import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/ride_booking.dart';
import '../widgets/choice_button.dart';
import '../widgets/input_field.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController nameController = TextEditingController(
    text: AppData.currentCustomerName,
  );
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  String rideType = 'Book Now';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  double _calculateEstimatedFare(double distanceKm) {
    return AppData.baseFare + (distanceKm * AppData.pricePerKm);
  }

  Future<void> _selectDateAndTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Select ride date',
      cancelText: 'Cancel',
      confirmText: 'Next',
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      helpText: 'Select ride time',
      cancelText: 'Cancel',
      confirmText: 'Done',
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
      selectedTime = pickedTime;

      final formattedDate =
          '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';

      final formattedTime =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

      dateTimeController.text = '$formattedDate at $formattedTime';
    });
  }

  Future<void> _submitBooking() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final pickup = pickupController.text.trim();
    final destination = destinationController.text.trim();
    final dateTime = dateTimeController.text.trim();
    final distanceText = distanceController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        pickup.isEmpty ||
        destination.isEmpty ||
        dateTime.isEmpty ||
        distanceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all booking details.'),
        ),
      );
      return;
    }

    final distanceKm = double.tryParse(distanceText);

    if (distanceKm == null || distanceKm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid distance in kilometres.'),
        ),
      );
      return;
    }

    final estimatedFare = _calculateEstimatedFare(distanceKm);

    final booking = RideBooking(
      customerName: name,
      phoneNumber: phone,
      pickupLocation: pickup,
      destination: destination,
      dateTime: dateTime,
      rideType: rideType,
      distanceKm: distanceKm,
      estimatedFare: estimatedFare,
    );

    await AppData.addBooking(booking);

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: booking),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    pickupController.dispose();
    destinationController.dispose();
    dateTimeController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = double.tryParse(distanceController.text.trim());
    final farePreview = distanceKm == null || distanceKm <= 0
        ? 0.0
        : _calculateEstimatedFare(distanceKm);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ride Details',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter the customer and trip details below.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 24),

              InputField(
                controller: nameController,
                label: 'Customer Name',
                icon: Icons.person_rounded,
              ),

              InputField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),

              InputField(
                controller: pickupController,
                label: 'Pickup Location',
                icon: Icons.my_location_rounded,
              ),

              InputField(
                controller: destinationController,
                label: 'Destination',
                icon: Icons.location_on_rounded,
              ),

              GestureDetector(
                onTap: _selectDateAndTime,
                child: AbsorbPointer(
                  child: InputField(
                    controller: dateTimeController,
                    label: 'Date and Time',
                    icon: Icons.calendar_month_rounded,
                    hint: 'Tap to choose date and time',
                  ),
                ),
              ),

              InputField(
                controller: distanceController,
                label: 'Distance in KM',
                icon: Icons.route_rounded,
                hint: 'Example: 12',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Fare',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            farePreview <= 0
                                ? 'Enter distance to calculate'
                                : 'R${farePreview.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Base fare R${AppData.baseFare.toStringAsFixed(2)} + R${AppData.pricePerKm.toStringAsFixed(2)} per km',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Ride Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ChoiceButton(
                      title: 'Book Now',
                      selected: rideType == 'Book Now',
                      onTap: () {
                        setState(() {
                          rideType = 'Book Now';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceButton(
                      title: 'Schedule',
                      selected: rideType == 'Schedule',
                      onTap: () {
                        setState(() {
                          rideType = 'Schedule';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Submit Booking',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}