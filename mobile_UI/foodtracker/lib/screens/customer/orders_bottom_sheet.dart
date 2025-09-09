// lib/widgets/orders_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class OrdersBottomSheet extends StatefulWidget {
  const OrdersBottomSheet({Key? key}) : super(key: key);

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
            _orders[index] = order;
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
                    'Your Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    onPressed: _loadOrders,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
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
          SizedBox(height: 8),


          _buildStatusDots(order.status),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                _formatTime(order.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDots(dynamic status) {
    final statuses = ['NEW', 'ACCEPTED', 'READY_FOR_PICKUP', 'PICKED_UP', 'DELIVERED'];
    final statusNames = ['New', 'Accepted', 'Ready', 'Picked Up', 'Delivered'];
    final currentIndex = _getStatusIndex(status);

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = index <= currentIndex;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              SizedBox(height: 4),
              Text(
                statusNames[index],
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.blue : Colors.grey[600],
                  fontWeight: index == currentIndex ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _getStatusIndex(dynamic status) {
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'NEW':
      case 'NEW_ORDER':
        return 0;
      case 'ACCEPTED':
        return 1;
      case 'READY_FOR_PICKUP':
      case 'READY':
        return 2;
      case 'PICKED_UP':
        return 3;
      case 'DELIVERED':
        return 4;
      default:
        return 0;
    }
  }

  String _getStatusText(dynamic status) {
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'NEW':
      case 'NEW_ORDER':
        return 'New Order';
      case 'ACCEPTED':
        return 'Accepted';
      case 'READY_FOR_PICKUP':
      case 'READY':
        return 'Ready for Pickup';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return 'New Order';
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

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown time';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}