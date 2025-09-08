// lib/screens/home_wrapper.dart
import 'package:flutter/material.dart';
import 'package:foodtracker/screens/restaurant/restaurant_home.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'customer/customer_home.dart';
import 'driver/driver_home.dart';


class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(body: Center(child: Text('No user found')));
    }

    // Route to appropriate home screen based on user type
    switch (user.type) {
      case UserType.customer:
        return CustomerHome();
      case UserType.driver:
        return DriverHome();
      case UserType.restaurant:
        return RestaurantHome();
      default:
        return Scaffold(
          body: Center(child: Text('Unknown user type: ${user.type}')),
        );
    }
  }
}