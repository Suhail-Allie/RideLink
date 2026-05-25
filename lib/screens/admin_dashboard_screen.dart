import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/summary_row.dart';
import 'admin_driver_management_screen.dart';
import 'admin_pricing_screen.dart';
import 'welcome_screen.dart';

/// AdminDashboardScreen
///
/// This screen is used by the taxi business owner/admin.
/// It shows a business overview of all bookings, trip statuses,
/// estimated revenue, pricing settings, driver management, and demo data tools.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  /// Logs the admin out and returns to the welcome screen.
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  /// Returns a colour based on the current booking status.
  /// This helps make booking statuses easier to understand visually.
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

    if (status == 'Cancelled by Driver') {
      return const Color(0xFFDC2626); // Red
    }

    return const Color(0xFFF59E0B); // Orange for pending/default
  }

  /// Clears all saved demo bookings after asking the admin to confirm.
  ///
  /// This is useful during testing because the app stores bookings locally.
  /// It does not clear pricing settings or driver profiles.
  Future<void> _clearDemoData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Demo Data?'),
          content: const Text(
            'This will remove all saved bookings from the app. This is useful for testing and demos.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AppData.clearBookings();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All demo bookings were cleared.'),
          ),
        );

        // Refresh the admin dashboard after clearing saved bookings.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all locally saved bookings from AppData.
    final bookings = AppData.bookings;

    // Business statistics shown on the admin dashboard.
    final totalBookings = bookings.length;

    final completedTrips = bookings
        .where((booking) => booking.status == 'Trip Completed')
        .length;

    final cancelledTrips = bookings
        .where((booking) => booking.status == 'Cancelled by Driver')
        .length;

    final activeTrips = bookings
        .where(
          (booking) =>
              booking.status != 'Trip Completed' &&
              booking.status != 'Cancelled by Driver',
        )
        .length;

    // Estimated revenue excludes cancelled trips.
    final estimatedRevenue = bookings
        .where((booking) => booking.status != 'Cancelled by Driver')
        .fold<double>(
          0,
          (total, booking) => total + booking.estimatedFare,
        );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header row with admin name and logout button.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Admin: ${AppData.currentAdminName}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Business overview for bookings, drivers, trips, and estimated revenue.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              // Main owner dashboard summary card.
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
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Owner Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Revenue summary.
                    Text(
                      'Estimated revenue: R${estimatedRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Current pricing summary.
                    Text(
                      'Current pricing: R${AppData.baseFare.toStringAsFixed(2)} base + R${AppData.pricePerKm.toStringAsFixed(2)} per km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Driver count summary.
                    Text(
                      'Registered drivers: ${AppData.drivers.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // First row of dashboard statistics.
              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Total',
                      value: totalBookings.toString(),
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Active',
                      value: activeTrips.toString(),
                      icon: Icons.directions_car_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Second row of dashboard statistics.
              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Completed',
                      value: completedTrips.toString(),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Cancelled',
                      value: cancelledTrips.toString(),
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Opens the admin driver management screen.
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDriverManagementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.groups_rounded),
                  label: const Text(
                    'Driver Management',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Opens the pricing settings screen.
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPricingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payments_rounded),
                  label: const Text(
                    'Pricing Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Clears all saved booking/demo data.
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _clearDemoData(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text(
                    'Clear Demo Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'All Bookings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 12),

              // Empty state when no bookings exist.
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
                    'No bookings yet. Customer ride requests will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                )
              else
                // List of all bookings submitted by customers.
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