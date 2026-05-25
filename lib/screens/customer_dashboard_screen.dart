import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/dashboard_stat_card.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';
import 'welcome_screen.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  void _openBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookingScreen()),
    );
  }

  void _openBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsCount = AppData.bookings.length;

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
                      'Hi, ${AppData.currentCustomerName}',
                      style: const TextStyle(
                        fontSize: 28,
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
                'Where would you like to go today?',
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
                      Color(0xFF1E3A8A),
                      Color(0xFF2563EB),
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Request a Taxi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Book a ride by entering your pickup point, destination, and preferred time.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Bookings',
                      value: bookingsCount.toString(),
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: DashboardStatCard(
                      title: 'Status',
                      value: 'MVP',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              DashboardActionCard(
                icon: Icons.add_road_rounded,
                title: 'Book a New Ride',
                subtitle: 'Submit a taxi request with trip details.',
                onTap: () => _openBooking(context),
              ),

              DashboardActionCard(
                icon: Icons.history_rounded,
                title: 'My Bookings',
                subtitle: 'View your submitted ride requests.',
                onTap: () => _openBookings(context),
              ),

              DashboardActionCard(
                icon: Icons.support_agent_rounded,
                title: 'Contact Taxi Business',
                subtitle: 'WhatsApp/call support will be connected later.',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact feature will be added later.'),
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