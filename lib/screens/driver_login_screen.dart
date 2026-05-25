import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/input_field.dart';
import 'driver_dashboard_screen.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _loginDriver() {
    final driverName = driverNameController.text.trim();
    final password = passwordController.text.trim();

    if (driverName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter driver name and password.'),
        ),
      );
      return;
    }

    final driver = AppData.findDriverByNameAndPassword(
      name: driverName,
      password: password,
    );

    if (driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Driver not found. Ask the admin to add this driver first.',
          ),
        ),
      );
      return;
    }

    AppData.currentDriverName = driver.name;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverDashboardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    driverNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDrivers = AppData.drivers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Login'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.drive_eta_rounded,
                  color: Color(0xFF1E3A8A),
                  size: 38,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Driver Access',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Drivers can view ride requests and update trip progress.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              if (!hasDrivers)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Text(
                    'No drivers have been added yet. Please log in as admin and add a driver first.',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (!hasDrivers) const SizedBox(height: 20),

              InputField(
                controller: driverNameController,
                label: 'Driver Name',
                icon: Icons.person_rounded,
              ),

              InputField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_rounded,
                obscureText: true,
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loginDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Login as Driver',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Driver accounts are currently managed by the admin. This is still MVP authentication and will be upgraded later.',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}