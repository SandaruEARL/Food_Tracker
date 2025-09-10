// lib/screens/driver/manage_orders_page.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';

class ManageOrdersPage extends StatelessWidget {
  final List<Order> myOrders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int orderId, String status) onUpdateOrderStatus;

  const ManageOrdersPage({
    Key? key,
    required this.myOrders,
    required this.isLoading,
    required this.onRefresh,
    required this.onUpdateOrderStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: myOrders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your accepted orders will appear here',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: myOrders.length,
                itemBuilder: (context, index) {
                  final order = myOrders[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              _buildStatusBadge(order.status),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total: \$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Customer: Customer Name',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_getActionButton(order) != null)
                                _getActionButton(order)!,
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.readyForPickup:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[700]!;
        break;
      case OrderStatus.pickedUp:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue[700]!;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _getActionButton(Order order) {
    switch (order.status) {
      case OrderStatus.pickedUp:
        return ElevatedButton(
          onPressed: () => onUpdateOrderStatus(order.id, OrderStatus.delivered),
          child: Text('Mark Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case OrderStatus.readyForPickup:
        return ElevatedButton(
          onPressed: () => onUpdateOrderStatus(order.id, OrderStatus.pickedUp),
          child: Text('Accept Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      default:
        return null;
    }
  }
}