// lib/screens/driver/manage_orders_page.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_tab_bar.dart';

class ManageOrdersPage extends StatefulWidget {
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
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['All', 'Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return widget.myOrders;
      case 1: // Pending (Ready for pickup)
        return widget.myOrders
            .where((order) => order.status == OrderStatus.readyForPickup)
            .toList();
      case 2: // In Progress (Picked up)
        return widget.myOrders
            .where((order) => order.status == OrderStatus.pickedUp)
            .toList();
      case 3: // Completed (Delivered)
        return widget.myOrders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
      default:
        return widget.myOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          // Header Section
          Row(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Orders',
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'hind',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getCurrentDateTitle(),
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'hind',
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          // Custom Tab Bar
          CustomTabBar(
            controller: _tabController,
            tabTitles: _tabTitles,
            margin: EdgeInsets.symmetric(horizontal: 15),
          ),
          SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: widget.isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: _tabTitles.asMap().entries.map((entry) {
                final tabIndex = entry.key;
                final filteredOrders = _getFilteredOrders(tabIndex);

                return RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  child: filteredOrders.isEmpty
                      ? _buildEmptyState(tabIndex)
                      : _buildOrdersList(filteredOrders),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No orders found';
        subtitle = 'Your accepted orders will appear here';
        icon = Icons.inbox;
        break;
      case 1:
        title = 'No pending orders';
        subtitle = 'Orders ready for pickup will appear here';
        icon = Icons.schedule;
        break;
      case 2:
        title = 'No orders in progress';
        subtitle = 'Orders you\'ve picked up will appear here';
        icon = Icons.local_shipping;
        break;
      case 3:
        title = 'No completed orders';
        subtitle = 'Your delivered orders will appear here';
        icon = Icons.check_circle_outline;
        break;
      default:
        title = 'No orders found';
        subtitle = 'Your orders will appear here';
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: 'hind',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'hind',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
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
                        fontFamily: 'hind',
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
                    fontFamily: 'hind',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Customer: Customer Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'hind',
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
    );
  }

  String _getCurrentDateTitle() {
    final now = DateTime.now();

    final dayFormatter = DateFormat('EEEE'); // Full day name
    final monthDayFormatter = DateFormat('MMMM d'); // Month and day number
    final yearFormatter = DateFormat('y'); // Year
    final timeFormatter = DateFormat('hh:mm a'); // Time with AM/PM

    return '${dayFormatter.format(now)}, ${monthDayFormatter.format(now)}, ${yearFormatter.format(now)}, ${timeFormatter.format(now)}';
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
          fontFamily: 'hind',
        ),
      ),
    );
  }

  Widget? _getActionButton(Order order) {
    switch (order.status) {
      case OrderStatus.pickedUp:
        return ElevatedButton(
          onPressed: () => widget.onUpdateOrderStatus(order.id, OrderStatus.delivered),
          child: Text('Mark Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: TextStyle(fontFamily: 'hind'),
          ),
        );
      case OrderStatus.readyForPickup:
        return ElevatedButton(
          onPressed: () => widget.onUpdateOrderStatus(order.id, OrderStatus.pickedUp),
          child: Text('Accept Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: TextStyle(fontFamily: 'hind'),
          ),
        );
      default:
        return null;
    }
  }
}