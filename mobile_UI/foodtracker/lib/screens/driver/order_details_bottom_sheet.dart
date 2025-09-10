// lib/widgets/order_details_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../utils/constants.dart';


class OrderDetailsBottomSheet extends StatelessWidget {
  final Order order;
  final bool isActiveOrder;
  final Function(int orderId, String status) onUpdateOrderStatus;

  const OrderDetailsBottomSheet({
    Key? key,
    required this.order,
    required this.isActiveOrder,
    required this.onUpdateOrderStatus,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        required Order order,
        required bool isActiveOrder,
        required Function(int orderId, String status) onUpdateOrderStatus,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return OrderDetailsBottomSheet(
          order: order,
          isActiveOrder: isActiveOrder,
          onUpdateOrderStatus: onUpdateOrderStatus,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Order ID Title
                  Text(
                    '#ORD-0000${order.id}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'hind',
                    ),
                  ),
                  SizedBox(height: 20),

                  // Description
                  _buildDetailRow(
                    'Description',
                    order.description ??
                        order.items?.map((item) => item.name).join(', ') ??
                        'Order details not available',
                  ),

                  // Customer
                  _buildDetailRow('Customer', 'Customer Name'), // You might want to add customer info to Order model

                  // Customer Phone
                  _buildDetailRow('Phone', '+94 71 234 ###'),

                  // Restaurant
                  _buildDetailRow('Restaurant', order.status ?? 'Restaurant Name'), // Add this to Order model if needed

                  // Status
                  _buildDetailRow(
                    'Status',
                    order.status,
                    isStatus: true,
                  ),

                  // Order Items (if available)
                  if (order.items != null && order.items!.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'hind',
                      ),
                    ),
                    SizedBox(height: 10),
                    ...order.items!.map((item) => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF6F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            'x${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],

                  SizedBox(height: 30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (isActiveOrder) {
                          onUpdateOrderStatus(order.id, OrderStatus.delivered);
                        } else {
                          onUpdateOrderStatus(order.id, OrderStatus.pickedUp);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActiveOrder ? Color(0xFFD2A146) : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isActiveOrder ? 'Mark Delivered' : 'Approve Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Add some bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(value).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(value),
                  width: 1,
                ),
              ),
              child: Text(
                value.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(value),
                  fontSize: 12,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'pickedup':
        return Color(0xFFD2A146);
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}