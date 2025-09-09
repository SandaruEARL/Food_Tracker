// lib/widgets/orders_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../../models/order.dart';


class OrdersBottomSheet extends StatelessWidget {
  final List<Order> orders;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const OrdersBottomSheet({
    Key? key,
    required this.orders,
    this.isLoading = false,
    this.onRefresh,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required List<Order> orders,
    bool isLoading = false,
    VoidCallback? onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrdersBottomSheet(
        orders: orders,
        isLoading: isLoading,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildOrdersList(scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(ScrollController scrollController) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Group orders by date
    Map<String, List<Order>> groupedOrders = {};
    for (var order in orders) {
      String dateKey = _formatDateForGrouping(order.createdAt ?? DateTime.now());
      if (!groupedOrders.containsKey(dateKey)) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(order);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedOrders.length,
        itemBuilder: (context, index) {
          String dateKey = groupedOrders.keys.elementAt(index);
          List<Order> dayOrders = groupedOrders[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...dayOrders.map((order) => _buildOrderItem(order)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${order.id}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  order.description ?? 'No description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusDisplayText(order.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'Today, ${_formatDate(date)}';
    } else if (orderDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday, ${_formatDate(date)}';
    } else {
      return _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'READY_FOR_PICKUP':
        return Colors.amber;
      case 'PICKED_UP':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'NEW':
        return 'Pending';
      case 'ACCEPTED':
        return 'Accepted';
      case 'READY_FOR_PICKUP':
        return 'Ready';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return status;
    }
  }
}