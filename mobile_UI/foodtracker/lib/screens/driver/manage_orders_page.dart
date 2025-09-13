// lib/screens/driver/manage_orders_page.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/custom_button.dart';
import 'bottom_sheets/order_details_bottom_sheet.dart';
import 'bottom_sheets/completed_order_details_sheet.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Manage Orders',
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'hind',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
            ),
          ],
        ),
        CustomTabBar(
          controller: _tabController,
          tabTitles: _getTabTitlesWithCount(),
          margin: EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabTitles.asMap().entries.map((entry) {
              final tabIndex = entry.key;
              return _buildOrdersTab(tabIndex);
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getTabTitlesWithCount() {
    return [
      'All(${widget.myOrders.length})',
      'Pending(${_getFilteredOrders(1).length})',
      'Progress(${_getFilteredOrders(2).length})',
      'Complete(${_getFilteredOrders(3).length})',
    ];
  }

  Widget _buildOrdersTab(int tabIndex) {
    final filteredOrders = _getFilteredOrders(tabIndex);

    return widget.isLoading
        ? Center()
        : RefreshIndicator(
      color: Color(0xFF0386D0),
      onRefresh: () async => widget.onRefresh(),
      child: filteredOrders.isEmpty
          ? _buildEmptyState(tabIndex)
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          if (tabIndex == 3) { // Completed tab
            return _buildCompletedOrderCard(filteredOrders[index]);
          } else {
            return _buildOrderCard(filteredOrders[index], tabIndex);
          }
        },
      ),
    );
  }

  // Cloned order card from driver dashboard for All, Pending, and In Progress tabs
  Widget _buildOrderCard(Order order, int tabIndex) {
    bool isActiveOrder = order.status == OrderStatus.pickedUp;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF6F5F5),
        borderRadius: BorderRadius.circular(isActiveOrder ? 20 : 10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isActiveOrder ? 20 : 10),
          onTap: () => _showOrderDetails(order, isActiveOrder),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              '#ORD-0000${order.id}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  order.description ??
                      order.items?.map((item) => item.name).join(', ') ??
                      'Order details not available',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '+94 71 234 ###',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrderActionButton(
                  isActiveOrder: isActiveOrder,
                  orderId: order.id,
                  onUpdateOrderStatus: widget.onUpdateOrderStatus,
                  hasActiveOrders: _getFilteredOrders(2).isNotEmpty, // Check if there are orders in progress
                ),
                SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_right, color: Color(0XFFA49E9E)),
              ],
            ),
            isThreeLine: false,
          ),
        ),
      ),
    );
  }

  // Cloned completed order card from completed orders bottom sheet
  Widget _buildCompletedOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
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
          contentPadding: EdgeInsets.all(16),
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

  // Cloned order details method from driver dashboard
  void _showOrderDetails(Order order, bool isActiveOrder) {
    OrderDetailsBottomSheet.show(
      context,
      order: order,
      isActiveOrder: isActiveOrder,
      onUpdateOrderStatus: widget.onUpdateOrderStatus,
      hasActiveOrders: _getFilteredOrders(2).isNotEmpty,
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

  String _getCurrentDateTitle() {
    final now = DateTime.now();

    final dayFormatter = DateFormat('EEEE'); // Full day name
    final monthDayFormatter = DateFormat('MMMM d'); // Month and day number
    final yearFormatter = DateFormat('y'); // Year
    final timeFormatter = DateFormat('hh:mm a'); // Time with AM/PM

    return '${dayFormatter.format(now)}, ${monthDayFormatter.format(now)}, ${yearFormatter.format(now)}, ${timeFormatter.format(now)}';
  }
}