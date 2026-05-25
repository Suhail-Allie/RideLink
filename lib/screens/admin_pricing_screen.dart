import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../widgets/input_field.dart';

class AdminPricingScreen extends StatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  State<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends State<AdminPricingScreen> {
  final TextEditingController baseFareController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    baseFareController.text = AppData.baseFare.toStringAsFixed(2);
    pricePerKmController.text = AppData.pricePerKm.toStringAsFixed(2);
  }

  Future<void> _savePricing() async {
    final baseFareText = baseFareController.text.trim();
    final pricePerKmText = pricePerKmController.text.trim();

    final newBaseFare = double.tryParse(baseFareText);
    final newPricePerKm = double.tryParse(pricePerKmText);

    if (newBaseFare == null || newBaseFare < 0) {
      _showMessage('Please enter a valid base fare.');
      return;
    }

    if (newPricePerKm == null || newPricePerKm <= 0) {
      _showMessage('Please enter a valid price per km.');
      return;
    }

    await AppData.savePricing(
      newBaseFare: newBaseFare,
      newPricePerKm: newPricePerKm,
    );

    if (!mounted) {
      return;
    }

    _showMessage('Pricing settings saved successfully.');
    Navigator.pop(context);
  }

  void _resetDefaultPricing() {
    baseFareController.text = '25.00';
    pricePerKmController.text = '12.00';

    _showMessage('Default pricing loaded. Tap Save Pricing to confirm.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    baseFareController.dispose();
    pricePerKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewDistance = 10.0;
    final previewBaseFare = double.tryParse(baseFareController.text) ?? 0.0;
    final previewPricePerKm = double.tryParse(pricePerKmController.text) ?? 0.0;
    final previewFare = previewBaseFare + (previewDistance * previewPricePerKm);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Settings'),
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
                      Icons.payments_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Business Pricing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set the base fare and price per kilometre used for fare estimates.',
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

              InputField(
                controller: baseFareController,
                label: 'Base Fare',
                icon: Icons.flag_rounded,
                hint: 'Example: 25',
                keyboardType: TextInputType.number,
              ),

              InputField(
                controller: pricePerKmController,
                label: 'Price Per KM',
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
                        Icons.calculate_rounded,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fare Preview',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '10 km = R${previewFare.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'R${previewBaseFare.toStringAsFixed(2)} base + R${previewPricePerKm.toStringAsFixed(2)} per km',
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

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _savePricing,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Pricing',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _resetDefaultPricing,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Reset to Default Pricing',
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

              const SizedBox(height: 16),

              const Text(
                'These settings are saved locally for the MVP. Later, they can be moved to Firebase or Supabase so the business owner can manage pricing online.',
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