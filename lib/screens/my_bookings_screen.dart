import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/summary_row.dart';

/// MyBookingsScreen
///
/// This screen allows the customer to view all ride bookings.
/// The customer can also cancel a booking before the trip has started.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  /// Returns a colour based on the booking status.
  /// This makes each booking status easier to identify visually.
  Color _statusColor(String status) {
    if (status == 'Trip Completed') {
      return const Color(0xFF16A34A); // Green
    }

    if (status == 'Trip Started') {
      return const Color(0xFF2563EB); // Blue
    }

    if (status == 'Accepted by Driver') {
      return const Color(0xFF7C3AED); // Purple
    }

    if (status == 'Assigned to Driver') {
      return const Color(0xFF0F766E); // Teal
    }

    if (status == 'Cancelled by Driver' || status == 'Cancelled by Customer') {
      return const Color(0xFFDC2626); // Red
    }

    return const Color(0xFFF59E0B); // Orange for pending/default
  }

  /// Checks if the customer is allowed to cancel this booking.
  ///
  /// Customers may cancel before the trip starts.
  /// They may not cancel after a trip has started, completed, or already cancelled.
  bool _canCancelBooking(String status) {
    return status != 'Trip Started' &&
        status != 'Trip Completed' &&
        status != 'Cancelled by Driver' &&
        status != 'Cancelled by Customer';
  }

  /// Cancels a customer booking after confirmation.
  ///
  /// The booking is not deleted. Its status changes to "Cancelled by Customer"
  /// so the admin and driver can still see what happened.
  Future<void> _cancelBooking(BuildContext context, dynamic booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action will update the booking status to Cancelled by Customer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        booking.status = 'Cancelled by Customer';
      });

      await AppData.saveBookings();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully.'),
          ),
        );
      }
    }
  }

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

                  final canCancel = _canCancelBooking(booking.status);

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
                        // Booking route title.
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

                        const SizedBox(height: 12),

                        // Status badge.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(booking.status)
                                .withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            booking.status,
                            style: TextStyle(
                              color: _statusColor(booking.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Booking details.
                        SummaryRow(
                          title: 'Customer',
                          value: booking.customerName,
                        ),
                        SummaryRow(
                          title: 'Phone',
                          value: booking.phoneNumber,
                        ),
                        SummaryRow(
                          title: 'Date/Time',
                          value: booking.dateTime,
                        ),
                        SummaryRow(
                          title: 'Ride Type',
                          value: booking.rideType,
                        ),
                        SummaryRow(
                          title: 'Distance',
                          value: '${booking.distanceKm.toStringAsFixed(1)} km',
                        ),
                        SummaryRow(
                          title: 'Fare',
                          value: 'R${booking.estimatedFare.toStringAsFixed(2)}',
                        ),
                        SummaryRow(
                          title: 'Driver',
                          value: booking.assignedDriver,
                        ),
                        SummaryRow(
                          title: 'Status',
                          value: booking.status,
                        ),

                        const SizedBox(height: 14),

                        // Customer can only cancel before the trip starts.
                        if (canCancel)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _cancelBooking(context, booking);
                              },
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text(
                                'Cancel Booking',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(
                                  color: Color(0xFFDC2626),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: const Text(
                              'This booking can no longer be cancelled.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}