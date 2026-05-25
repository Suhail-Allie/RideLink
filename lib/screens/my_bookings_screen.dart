import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/summary_row.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = AppData.bookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: bookings.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No bookings yet. Book your first ride from the dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(22),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_taxi_rounded,
                              color: Color(0xFF1E3A8A),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${booking.pickupLocation} → ${booking.destination}',
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SummaryRow(title: 'Customer', value: booking.customerName),
                        SummaryRow(title: 'Phone', value: booking.phoneNumber),
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
                        SummaryRow(title: 'Driver', value: booking.assignedDriver),
                        SummaryRow(title: 'Status', value: booking.status),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}