import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/order.dart';

class CompletedOrderDetailsSheet extends StatefulWidget {
  final Order order;

  const CompletedOrderDetailsSheet({
    Key? key,
    required this.order,
  }) : super(key: key);

  static void show(BuildContext context, {required Order order}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CompletedOrderDetailsSheet(order: order);
      },
    );
  }

  @override
  State<CompletedOrderDetailsSheet> createState() => _CompletedOrderDetailsSheetState();
}

class _CompletedOrderDetailsSheetState extends State<CompletedOrderDetailsSheet> {
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
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

                  // Order ID Title with close button
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
                            padding: const EdgeInsets.symmetric(horizontal: 140),
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
                    decoration: BoxDecoration(color: Color(0xFFF6F5F5),borderRadius: BorderRadius.circular(10)),
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
                    
                        // Restaurant Address
                        _buildDetailRow('Address', 'N/A'),
                    
                        // Customer Address
                        _buildDetailRow('Delivery Address', 'N/A'),
                    
                        // Total Amount
                        _buildDetailRow('Total Amount', 'N/A'),
                    
                        // Completed Date
                        _buildDetailRow(
                            'Completed On',
                            widget.order.createdAt != null ? _formatDate(widget.order.createdAt!) : 'N/A'
                        ),
                    
                        // Status
                        _buildDetailRow(
                          'Status',
                          widget.order.status,
                          isStatus: true,
                        ),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
          SizedBox(width: 30),
          Expanded( // Expanded is directly inside Row
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
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
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
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}