// lib/screens/restaurant/retaurent_summery_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class RestaurantSummaryBottomSheet extends StatelessWidget {
  final List<Order> availableOrders;
  final List<Order> inProgressOrders;
  final List<Order> completedTodayOrders;

  const RestaurantSummaryBottomSheet({
    super.key,
    required this.availableOrders,
    required this.inProgressOrders,
    required this.completedTodayOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Today\'s Summary',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.xmark, color: Colors.grey[600]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Current timestamp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getCurrentDateTitle(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Stats
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatCard(
                      'Available Orders',
                      '${availableOrders.length}',

                    ),
                    const SizedBox(height: 20),

                    _buildStatCard(
                      'In Progress',
                      '${inProgressOrders.length}',

                    ),
                    const SizedBox(height: 20),

                    _buildStatCard(
                      'Completed Today',
                      '${completedTodayOrders.length}',


                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getCurrentDateTitle() {
    final now = DateTime.now();
    final dayFormatter = DateFormat('EEEE'); // Full day name
    final monthDayFormatter = DateFormat('MMM d'); // Abbreviated month name and day number
    final yearFormatter = DateFormat('y'); // Year

    return '${dayFormatter.format(now)}, ${monthDayFormatter.format(now)}, ${yearFormatter.format(now)}';
  }

  Widget _buildStatCard(String title, String value,) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'hind',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'hind',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static void show(BuildContext context, List<Order> availableOrders, List<Order> myOrders) {
    // Filter myOrders to get inProgressOrders and completedTodayOrders
    List<Order> inProgressOrders = myOrders.where((order) =>
    order.status == OrderStatus.accepted ||
        order.status == OrderStatus.readyForPickup
    ).toList();

    List<Order> completedTodayOrders = myOrders.where((order) =>
    order.status == OrderStatus.readyForPickup &&
        order.createdAt != null &&
        _isToday(order.createdAt!)
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RestaurantSummaryBottomSheet(
          availableOrders: availableOrders,
          inProgressOrders: inProgressOrders,
          completedTodayOrders: completedTodayOrders,
        );
      },
    );
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}