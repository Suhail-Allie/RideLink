import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/ride_booking.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/summary_row.dart';
import 'admin_driver_management_screen.dart';
import 'admin_pricing_screen.dart';
import 'welcome_screen.dart';

/// AdminDashboardScreen
///
/// This screen is used by the taxi business owner/admin.
/// It shows all bookings, business statistics, revenue,
/// pricing settings, driver management, driver assignment,
/// and booking status filtering.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  /// The currently selected booking filter.
  String selectedFilter = 'All';

  /// Available filters shown above the booking list.
  final List<String> filters = [
    'All',
    'Pending',
    'Assigned',
    'Accepted',
    'Started',
    'Completed',
    'Cancelled',
  ];

  /// Logs the admin out and returns to the welcome screen.
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  /// Returns a colour based on the booking status.
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

    if (status == 'Cancelled by Driver' || status == 'Cancelled by Customer') {
      return const Color(0xFFDC2626);
    }

    return const Color(0xFFF59E0B);
  }

  /// Clears all saved bookings after confirmation.
  ///
  /// This is only for MVP/demo testing.
  /// It does not clear drivers or pricing.
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
        setState(() {
          selectedFilter = 'All';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All demo bookings were cleared.'),
          ),
        );
      }
    }
  }

  /// Opens a dialog that allows the admin to assign a registered driver
  /// to a selected booking.
  Future<void> _assignDriverToBooking(
    BuildContext context,
    RideBooking booking,
  ) async {
    if (AppData.drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add drivers before assigning bookings.'),
        ),
      );
      return;
    }

    if (!_canAssignDriver(booking)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This booking can no longer be assigned.'),
        ),
      );
      return;
    }

    final selectedDriverName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Assign Driver'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${booking.pickupLocation} → ${booking.destination}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Show each registered driver as an option.
            ...AppData.drivers.map((driver) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(dialogContext, driver.name);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.drive_eta_rounded,
                      color: Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${driver.name} • ${driver.vehicle}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );

    if (selectedDriverName == null) {
      return;
    }

    setState(() {
      booking.assignedDriver = selectedDriverName;
      booking.status = 'Assigned to Driver';
    });

    await AppData.saveBookings();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking assigned to $selectedDriverName.'),
        ),
      );
    }
  }

  /// Returns bookings based on the selected admin filter.
  ///
  /// This method checks both the booking status and assigned driver,
  /// because pending bookings are identified by having no assigned driver yet.
  List<RideBooking> _filteredBookings(List<RideBooking> bookings) {
    if (selectedFilter == 'All') {
      return bookings;
    }

    if (selectedFilter == 'Pending') {
      return bookings.where((booking) {
        final hasNoDriver = booking.assignedDriver == 'Not assigned yet';

        final isNotFinished = booking.status != 'Trip Completed' &&
            booking.status != 'Trip Started' &&
            booking.status != 'Accepted by Driver' &&
            booking.status != 'Assigned to Driver' &&
            booking.status != 'Cancelled by Driver' &&
            booking.status != 'Cancelled by Customer';

        return hasNoDriver && isNotFinished;
      }).toList();
    }

    if (selectedFilter == 'Assigned') {
      return bookings.where((booking) {
        return booking.status == 'Assigned to Driver';
      }).toList();
    }

    if (selectedFilter == 'Accepted') {
      return bookings.where((booking) {
        return booking.status == 'Accepted by Driver';
      }).toList();
    }

    if (selectedFilter == 'Started') {
      return bookings.where((booking) {
        return booking.status == 'Trip Started';
      }).toList();
    }

    if (selectedFilter == 'Completed') {
      return bookings.where((booking) {
        return booking.status == 'Trip Completed';
      }).toList();
    }

    if (selectedFilter == 'Cancelled') {
      return bookings.where((booking) {
        return booking.status == 'Cancelled by Driver' ||
            booking.status == 'Cancelled by Customer';
      }).toList();
    }

    return bookings;
  }

  /// Checks if the admin can still assign a driver to this booking.
  ///
  /// Admin should not assign drivers to trips that already started,
  /// completed, or were cancelled.
  bool _canAssignDriver(RideBooking booking) {
    return booking.status != 'Trip Completed' &&
        booking.status != 'Trip Started' &&
        booking.status != 'Cancelled by Driver' &&
        booking.status != 'Cancelled by Customer';
  }

  @override
  Widget build(BuildContext context) {
    final bookings = AppData.bookings;
    final visibleBookings = _filteredBookings(bookings);

    final totalBookings = bookings.length;

    final completedTrips = bookings
        .where((booking) => booking.status == 'Trip Completed')
        .length;

    final cancelledTrips = bookings
        .where(
          (booking) =>
              booking.status == 'Cancelled by Driver' ||
              booking.status == 'Cancelled by Customer',
        )
        .length;

    final activeTrips = bookings
        .where(
          (booking) =>
              booking.status != 'Trip Completed' &&
              booking.status != 'Cancelled by Driver' &&
              booking.status != 'Cancelled by Customer',
        )
        .length;

    final estimatedRevenue = bookings
        .where(
          (booking) =>
              booking.status != 'Cancelled by Driver' &&
              booking.status != 'Cancelled by Customer',
        )
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

              // Header with admin name and logout button.
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

              // Main admin summary card.
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
                    Text(
                      'Estimated revenue: R${estimatedRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current pricing: R${AppData.baseFare.toStringAsFixed(2)} base + R${AppData.pricePerKm.toStringAsFixed(2)} per km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
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

              // Dashboard statistics row one.
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

              // Dashboard statistics row two.
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

              // Opens driver management screen.
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

              // Opens pricing settings screen.
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

              // Clears all saved demo booking data.
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

              // Booking list heading.
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All Bookings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Text(
                    '${visibleBookings.length} shown',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Horizontal booking status filter chips.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) {
                    final isSelected = selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        selectedColor: const Color(0xFF1E3A8A),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.bold,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFFE5E7EB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

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
              else if (visibleBookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    'No bookings found for the "$selectedFilter" filter.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: visibleBookings.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final booking = visibleBookings[index];
                    final canAssignDriver = _canAssignDriver(booking);

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

                          // Booking status badge.
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

                          const SizedBox(height: 14),

                          if (canAssignDriver)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _assignDriverToBooking(context, booking);
                                },
                                icon: const Icon(
                                  Icons.assignment_ind_rounded,
                                ),
                                label: const Text(
                                  'Assign Driver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(
                                    color: Color(0xFF1E3A8A),
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
                                'This booking can no longer be assigned.',
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
            ],
          ),
        ),
      ),
    );
  }
}