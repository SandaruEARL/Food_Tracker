// lib/screens/driver/driver_dashboard_page.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_tab_bar.dart';
import 'order_details_bottom_sheet.dart';

class DriverDashboardPage extends StatefulWidget {
  final List<Order> availableOrders;
  final List<Order> activeOrders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int orderId, String status) onUpdateOrderStatus;

  const DriverDashboardPage({
    super.key,
    required this.availableOrders,
    required this.activeOrders,
    required this.isLoading,
    required this.onRefresh,
    required this.onUpdateOrderStatus,
  });

  @override
  _DriverDashboardPageState createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                children: [
                  Text(
                    'Driver Dashboard',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'hind',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Saturday, September 6, 2025, 11:35 AM',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'hind',
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        CustomTabBar(
          controller: _tabController,
          tabTitles: [
            'All(${widget.availableOrders.length})',
            'Active(${widget.activeOrders.length})',
            'Map'
          ],
          margin: EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAvailableOrdersTab(),
              _buildActiveOrdersTab(),
              _buildDeliveryMapTab(),
            ],
          ),
        ),
      ],
    );
  }

  void _showOrderDetails(Order order, bool isActiveOrder) {
    OrderDetailsBottomSheet.show(
      context,
      order: order,
      isActiveOrder: isActiveOrder,
      onUpdateOrderStatus: widget.onUpdateOrderStatus,
    );
  }

  Widget _buildOrderCard(Order order, bool isActiveOrder) {
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
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActiveOrder ? Color(0xFFD2A146) : Colors.green,
                borderRadius: BorderRadius.circular(isActiveOrder ? 10 : 20),
              ),
              child: InkWell(
                onTap: () {
                  // Prevent the tap from bubbling up to the card
                  if (isActiveOrder) {
                    widget.onUpdateOrderStatus(order.id, OrderStatus.delivered);
                  } else {
                    widget.onUpdateOrderStatus(order.id, OrderStatus.pickedUp);
                  }
                },
                child: Text(
                  isActiveOrder ? 'Mark Delivered' : 'Approve',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            isThreeLine: false,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableOrdersTab() {
    return widget.isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.availableOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(widget.availableOrders[index], false);
        },
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    return widget.isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: widget.activeOrders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.activeOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(widget.activeOrders[index], true);
        },
      ),
    );
  }

  Widget _buildDeliveryMapTab() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Delivery Map',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Map integration coming soon',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}