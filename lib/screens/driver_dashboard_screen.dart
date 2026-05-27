import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/ride_booking.dart';
import '../widgets/summary_row.dart';
import 'welcome_screen.dart';

/// DriverDashboardScreen
///
/// This screen is used by logged-in drivers.
/// Drivers can view unassigned bookings and bookings assigned to them.
/// They can accept, start, complete, or cancel trips.
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  /// Logs the driver out and returns to the welcome screen.
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  /// Driver accepts the ride.
  Future<void> _acceptRide(RideBooking booking) async {
    setState(() {
      booking.status = 'Accepted by Driver';
      booking.assignedDriver = AppData.currentDriverName;
    });

    await AppData.saveBookings();

    _showMessage('Ride accepted.');
  }

  /// Driver starts the trip.
  Future<void> _startRide(RideBooking booking) async {
    setState(() {
      booking.status = 'Trip Started';
      booking.assignedDriver = AppData.currentDriverName;
    });

    await AppData.saveBookings();

    _showMessage('Trip started.');
  }

  /// Driver completes the trip.
  Future<void> _completeRide(RideBooking booking) async {
    setState(() {
      booking.status = 'Trip Completed';
      booking.assignedDriver = AppData.currentDriverName;
    });

    await AppData.saveBookings();

    _showMessage('Trip completed.');
  }

  /// Driver cancels the trip.
  Future<void> _cancelRide(RideBooking booking) async {
    setState(() {
      booking.status = 'Cancelled by Driver';
      booking.assignedDriver = AppData.currentDriverName;
    });

    await AppData.saveBookings();

    _showMessage('Trip cancelled.');
  }

  /// Shows a short message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Returns a colour based on booking status.
  Color _statusColor(String status) {
    if (status == 'Trip Completed') {
      return const Color(0xFF16A34A);
    }

    if (status == 'Trip Started') {
      return const Color(0xFF2563EB);
    }

    if (status == 'Accepted by Driver') {
      return const Color(0xFF7C3AED);
    }

    if (status == 'Assigned to Driver') {
      return const Color(0xFF0F766E);
    }

    if (status == 'Cancelled by Driver') {
      return const Color(0xFFDC2626);
    }

    return const Color(0xFFF59E0B);
  }

  /// Controls which bookings a driver is allowed to see.
  ///
  /// A driver can see:
  /// - bookings that are not assigned yet
  /// - bookings assigned to the current driver
  List<RideBooking> _visibleBookingsForDriver() {
    return AppData.bookings.where((booking) {
      final isUnassigned = booking.assignedDriver == 'Not assigned yet';
      final isAssignedToCurrentDriver =
          booking.assignedDriver == AppData.currentDriverName;

      return isUnassigned || isAssignedToCurrentDriver;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _visibleBookingsForDriver();

    final activeBookings =
        bookings.where((booking) => booking.status != 'Trip Completed').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Driver: ${AppData.currentDriverName}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'View assigned ride requests and update trip progress.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF1E3A8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.drive_eta_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Driver Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${bookings.length} visible booking(s) • $activeBookings active',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (bookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text(
                    'No bookings are available for this driver yet. Assigned or unassigned bookings will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: bookings.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _statusColor(booking.status).withOpacity(0.10),
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
                            value:
                                '${booking.distanceKm.toStringAsFixed(1)} km',
                          ),
                          SummaryRow(
                            title: 'Fare',
                            value:
                                'R${booking.estimatedFare.toStringAsFixed(2)}',
                          ),
                          SummaryRow(
                            title: 'Driver',
                            value: booking.assignedDriver,
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _DriverActionButton(
                                text: 'Accept',
                                icon: Icons.check_rounded,
                                onPressed: () {
                                  _acceptRide(booking);
                                },
                              ),
                              _DriverActionButton(
                                text: 'Start',
                                icon: Icons.play_arrow_rounded,
                                onPressed: () {
                                  _startRide(booking);
                                },
                              ),
                              _DriverActionButton(
                                text: 'Complete',
                                icon: Icons.flag_rounded,
                                onPressed: () {
                                  _completeRide(booking);
                                },
                              ),
                              _DriverActionButton(
                                text: 'Cancel',
                                icon: Icons.close_rounded,
                                isDanger: true,
                                onPressed: () {
                                  _cancelRide(booking);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable button used for driver trip actions.
class _DriverActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDanger;

  const _DriverActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFDC2626) : const Color(0xFF1E3A8A);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}