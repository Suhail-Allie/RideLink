import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/driver_profile.dart';
import '../widgets/input_field.dart';
import '../widgets/summary_row.dart';

class AdminDriverManagementScreen extends StatefulWidget {
  const AdminDriverManagementScreen({super.key});

  @override
  State<AdminDriverManagementScreen> createState() =>
      _AdminDriverManagementScreenState();
}

class _AdminDriverManagementScreenState
    extends State<AdminDriverManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _addDriver() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final vehicle = vehicleController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || vehicle.isEmpty || password.isEmpty) {
      _showMessage('Please complete all driver details.');
      return;
    }

    final alreadyExists = AppData.drivers.any(
      (driver) => driver.name.toLowerCase().trim() == name.toLowerCase().trim(),
    );

    if (alreadyExists) {
      _showMessage('A driver with this name already exists.');
      return;
    }

    final driver = DriverProfile(
      name: name,
      phoneNumber: phone,
      vehicle: vehicle,
      password: password,
    );

    await AppData.addDriver(driver);

    setState(() {
      nameController.clear();
      phoneController.clear();
      vehicleController.clear();
      passwordController.clear();
    });

    _showMessage('Driver added successfully.');
  }

  Future<void> _deleteDriver(DriverProfile driver) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Driver?'),
          content: Text(
            'Are you sure you want to delete ${driver.name} from the driver list?',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AppData.deleteDriver(driver);

      setState(() {});

      _showMessage('Driver deleted.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    vehicleController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drivers = AppData.drivers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Manage Drivers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add and manage drivers that can log in and handle bookings.',
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

              const Text(
                'Add New Driver',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 14),

              InputField(
                controller: nameController,
                label: 'Driver Name',
                icon: Icons.person_rounded,
              ),

              InputField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),

              InputField(
                controller: vehicleController,
                label: 'Vehicle Details',
                icon: Icons.local_taxi_rounded,
                hint: 'Example: Toyota Avanza - CA 123 456',
              ),

              InputField(
                controller: passwordController,
                label: 'Driver Password',
                icon: Icons.lock_rounded,
                obscureText: true,
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _addDriver,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Add Driver',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Registered Drivers (${drivers.length})',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 14),

              if (drivers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text(
                    'No drivers have been added yet. Add a driver above so they can log in and manage ride requests.',
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
                  itemCount: drivers.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final driver = drivers[index];

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
                                Icons.drive_eta_rounded,
                                color: Color(0xFF1E3A8A),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  driver.name,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deleteDriver(driver),
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: const Color(0xFFDC2626),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SummaryRow(
                            title: 'Phone',
                            value: driver.phoneNumber,
                          ),
                          SummaryRow(
                            title: 'Vehicle',
                            value: driver.vehicle,
                          ),
                          SummaryRow(
                            title: 'Login',
                            value: 'Driver can log in using this name and password.',
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              const Text(
                'This is MVP driver management. In the production version, passwords should be securely stored using real authentication.',
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