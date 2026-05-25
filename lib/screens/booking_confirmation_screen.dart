import 'package:flutter/material.dart';

import '../models/ride_booking.dart';
import '../widgets/summary_row.dart';
import 'customer_dashboard_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final RideBooking booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1E3A8A),
                        size: 44,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Booking Submitted',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'The taxi business can now review and assign a driver.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SummaryRow(title: 'Customer', value: booking.customerName),
                    SummaryRow(title: 'Phone', value: booking.phoneNumber),
                    SummaryRow(title: 'Pickup', value: booking.pickupLocation),
                    SummaryRow(title: 'Destination', value: booking.destination),
                    SummaryRow(title: 'Date/Time', value: booking.dateTime),
                    SummaryRow(title: 'Ride Type', value: booking.rideType),
                    SummaryRow(
                      title: 'Distance',
                      value: '${booking.distanceKm.toStringAsFixed(1)} km',
                    ),
                    SummaryRow(
                      title: 'Fare',
                      value: 'R${booking.estimatedFare.toStringAsFixed(2)}',
                    ),
                    SummaryRow(title: 'Status', value: booking.status),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerDashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
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