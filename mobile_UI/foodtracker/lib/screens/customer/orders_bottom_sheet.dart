// lib/widgets/orders_bottom_sheet.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';


class OrdersBottomSheet extends StatefulWidget {
  const OrdersBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrdersBottomSheet(),
    );
  }

  @override
  State<OrdersBottomSheet> createState() => _OrdersBottomSheetState();
}

class _OrdersBottomSheetState extends State<OrdersBottomSheet> {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;
  bool isClearing = false;
  Map<String, DateTime> deliveryTimes = {}; // Store delivery times by order ID

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebSocketListener();
  }

  void _setupWebSocketListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.webSocketService.onOrderUpdate = (order) {
      if (mounted) {
        setState(() {
          final index = _orders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            final previousOrder = _orders[index];

            // Check if status changed to delivered
            if (!_isDelivered(previousOrder.status) && _isDelivered(order.status)) {
              deliveryTimes[order.id.toString()] = DateTime.now();
            }

            _orders[index] = order;
          } else {
            // New order, check if it's already delivered
            if (_isDelivered(order.status)) {
              deliveryTimes[order.id.toString()] = DateTime.now();
            }
          }
        });
      }
    };
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _apiService.getRelevantOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;

          // Debug: Print order details
          for (final order in orders) {
            if (kDebugMode) {
              print('Order ${order.id}:');
              print('  - createdAt: ${order.createdAt}');
              print('  - status: ${order.status}');
              print('  - description: ${order.description}');
            }


            if (_isDelivered(order.status) && !deliveryTimes.containsKey(order.id.toString())) {
              deliveryTimes[order.id.toString()] = DateTime.now();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCurrentDateTitle() {
    final now = DateTime.now();
    final dayFormatter = DateFormat('EEEE'); // Full day name
    final monthDayFormatter = DateFormat('MMM d'); // Abbreviated month name and day number
    final yearFormatter = DateFormat('y'); // Year

    return '${dayFormatter.format(now)}, ${monthDayFormatter.format(now)}, ${yearFormatter.format(now)}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    _getCurrentDateTitle(),
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Close button
                  Expanded(
                    child: IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:40),
                        child: Icon(FontAwesomeIcons.timesCircle, color: Colors.grey[600]),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading || isClearing
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    if (isClearing) ...[
                      SizedBox(height: 16),
                      Text(
                        'Clearing order history...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              )
                  : _orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _orders.length,
                itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text('Your orders will appear here', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final String statusText = _getStatusText(order.status);
    final Color statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${order.id}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues()),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (order.description?.isNotEmpty == true)
            Text(order.description!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 12),
          _buildTimeInfo(order),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(Order order) {
    return Row(
      children: [
        // Placed time - only use createdAt
        Expanded(
          child: Row(
            children: [

              SizedBox(width: 4),

            ],
          ),
        ),
        SizedBox(width: 16),
        // Delivered time (only show if delivered)
        if (_isDelivered(order.status))
          Expanded(
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Delivered: ${_formatOrderTime(deliveryTimes[order.id.toString()])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          Expanded(child: SizedBox()),
      ],
    );
  }



  bool _isDelivered(dynamic status) {
    final statusStr = status.toString().toUpperCase();
    return statusStr == 'DELIVERED';
  }

  String _getStatusText(dynamic status) {
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'NEW':
      case 'NEW_ORDER':
        return 'New';
      case 'ACCEPTED':
        return 'Accepted';
      case 'READY_FOR_PICKUP':
      case 'READY':
        return 'Ready';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return 'New';
    }
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'NEW':
      case 'NEW_ORDER':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'READY_FOR_PICKUP':
      case 'READY':
        return Colors.purple;
      case 'PICKED_UP':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatOrderTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      final timeFormatter = DateFormat('h:mm a');
      return timeFormatter.format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}