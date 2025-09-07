import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/location.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  Function(Location)? onLocationUpdate;

  // Check and request location permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location once
  Future<Location?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return Location(lat: position.latitude, lng: position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Start tracking location continuously (for drivers)
  Future<void> startLocationTracking() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final location = Location(
          lat: position.latitude,
          lng: position.longitude
      );
      onLocationUpdate?.call(location);
    });
  }

  // Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // Check if currently tracking
  bool get isTracking => _positionStream != null;

  void dispose() {
    stopLocationTracking();
  }
}