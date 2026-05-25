import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver_profile.dart';
import '../models/ride_booking.dart';

class AppData {
  static const String _bookingsKey = 'ridelink_bookings';
  static const String _driversKey = 'ridelink_drivers';
  static const String _baseFareKey = 'ridelink_base_fare';
  static const String _pricePerKmKey = 'ridelink_price_per_km';

  static String currentCustomerName = 'Customer';
  static String currentDriverName = 'Driver';
  static String currentAdminName = 'Admin';

  static double baseFare = 25.0;
  static double pricePerKm = 12.0;

  static final List<RideBooking> bookings = [];
  static final List<DriverProfile> drivers = [];

  static Future<void> loadAppData() async {
    await loadPricing();
    await loadBookings();
    await loadDrivers();
  }

  static Future<void> loadPricing() async {
    final prefs = await SharedPreferences.getInstance();

    baseFare = prefs.getDouble(_baseFareKey) ?? 25.0;
    pricePerKm = prefs.getDouble(_pricePerKmKey) ?? 12.0;
  }

  static Future<void> savePricing({
    required double newBaseFare,
    required double newPricePerKm,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    baseFare = newBaseFare;
    pricePerKm = newPricePerKm;

    await prefs.setDouble(_baseFareKey, baseFare);
    await prefs.setDouble(_pricePerKmKey, pricePerKm);
  }

  static Future<void> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookings = prefs.getString(_bookingsKey);

    if (savedBookings == null || savedBookings.isEmpty) {
      return;
    }

    try {
      final decodedData = jsonDecode(savedBookings);

      if (decodedData is List) {
        bookings.clear();

        for (final item in decodedData) {
          if (item is Map<String, dynamic>) {
            bookings.add(RideBooking.fromJson(item));
          } else if (item is Map) {
            bookings.add(
              RideBooking.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
    } catch (_) {
      bookings.clear();
    }
  }

  static Future<void> saveBookings() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedBookings = jsonEncode(
      bookings.map((booking) => booking.toJson()).toList(),
    );

    await prefs.setString(_bookingsKey, encodedBookings);
  }

  static Future<void> addBooking(RideBooking booking) async {
    bookings.add(booking);
    await saveBookings();
  }

  static Future<void> clearBookings() async {
    bookings.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookingsKey);
  }

  static Future<void> loadDrivers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDrivers = prefs.getString(_driversKey);

    if (savedDrivers == null || savedDrivers.isEmpty) {
      return;
    }

    try {
      final decodedData = jsonDecode(savedDrivers);

      if (decodedData is List) {
        drivers.clear();

        for (final item in decodedData) {
          if (item is Map<String, dynamic>) {
            drivers.add(DriverProfile.fromJson(item));
          } else if (item is Map) {
            drivers.add(
              DriverProfile.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
    } catch (_) {
      drivers.clear();
    }
  }

  static Future<void> saveDrivers() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedDrivers = jsonEncode(
      drivers.map((driver) => driver.toJson()).toList(),
    );

    await prefs.setString(_driversKey, encodedDrivers);
  }

  static Future<void> addDriver(DriverProfile driver) async {
    drivers.add(driver);
    await saveDrivers();
  }

  static Future<void> deleteDriver(DriverProfile driver) async {
    drivers.remove(driver);
    await saveDrivers();
  }

  static DriverProfile? findDriverByNameAndPassword({
    required String name,
    required String password,
  }) {
    for (final driver in drivers) {
      if (driver.name.toLowerCase().trim() == name.toLowerCase().trim() &&
          driver.password == password) {
        return driver;
      }
    }

    return null;
  }
}