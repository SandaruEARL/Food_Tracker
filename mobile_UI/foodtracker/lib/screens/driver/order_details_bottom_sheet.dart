// lib/widgets/order_details_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/order.dart';
import '../../utils/constants.dart';


class OrderDetailsBottomSheet extends StatefulWidget {
  final Order order;
  final bool isActiveOrder;
  final Function(int orderId, String status) onUpdateOrderStatus;

  const OrderDetailsBottomSheet({
    super.key,
    required this.order,
    required this.isActiveOrder,
    required this.onUpdateOrderStatus,
  });

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
  State<OrderDetailsBottomSheet> createState() => _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<OrderDetailsBottomSheet> {
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
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 22),
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

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            '#ORD-0000${widget.order.id}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'hind',
                            ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:140),
                            child: Icon(FontAwesomeIcons.timesCircle, color: Colors.grey[600]),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),



                  SizedBox(height: 20),

                  // Description
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Color(0xFFF6F5F5),borderRadius: BorderRadius.circular(10),),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Description',
                          widget.order.description ??
                              widget.order.items?.map((item) => item.name).join(', ') ??
                              'Order details not available',
                        ),

                        // Customer
                        _buildDetailRow('Customer', 'N/A'),

                        // Customer Phone
                        _buildDetailRow('Phone', 'N/A'),

                        // Restaurant
                        _buildDetailRow('Restaurant', 'N/A'),
                        // Status
                        _buildDetailRow(
                          'Status',
                          widget.order.status,
                          isStatus: true,
                        ),

                        // Actions with Button
                        _buildActionRow(context),
                      ],
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
      padding: EdgeInsets.only(bottom: 16,),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: isStatus
                  ? Text(
                value.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(value),
                  fontSize: 12,
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          child: Text(
            'Actions:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(width: 50,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:26.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isActiveOrder ? Color(0xFFD2A146) : Colors.green,
              borderRadius: BorderRadius.circular(widget.isActiveOrder ? 10 : 10),
            ),
            child: InkWell(
              onTap: () {
                // Close the bottom sheet first
                Navigator.pop(context);

                // Prevent the tap from bubbling up to the card
                if (widget.isActiveOrder) {
                  widget.onUpdateOrderStatus(widget.order.id, OrderStatus.delivered);
                } else {
                  widget.onUpdateOrderStatus(widget.order.id, OrderStatus.pickedUp);
                }
              },
              child: Text(
                widget.isActiveOrder ? 'Mark Delivered' : 'Approve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
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