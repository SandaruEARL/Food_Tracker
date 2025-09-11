import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/order.dart';
import 'completed_order_details_sheet.dart';


class CompletedOrdersBottomSheet extends StatelessWidget {
  final List<Order> completedOrders;
  final bool isLoading;
  final VoidCallback onRefresh;

  const CompletedOrdersBottomSheet({
    Key? key,
    required this.completedOrders,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        required List<Order> completedOrders,
        required bool isLoading,
        required VoidCallback onRefresh,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CompletedOrdersBottomSheet(
          completedOrders: completedOrders,
          isLoading: isLoading,
          onRefresh: onRefresh,
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
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                    child: Text(
                      'Completed Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'hind',
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 75),
                        child: Icon(FontAwesomeIcons.timesCircle, color: Colors.grey[600]),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),

              // Content
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Color(0xFF0386D0)))
                    : completedOrders.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed orders',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  color: Color(0xFF0386D0),
                  onRefresh: () async => onRefresh(),
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      return _buildCompletedOrderCard(context, completedOrders[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompletedOrderCard(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () {
        // Show order details in the OrderDetailsBottomSheet
        // For completed orders, isActiveOrder should be false
        CompletedOrderDetailsSheet.show(
          context,
          order: order,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF6F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(

          title: Text(
            '#ORD-0000${order.id}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text(
                order.description ?? 'Order details not available',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'hind',
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),

        ),
      ),
    );
  }
}