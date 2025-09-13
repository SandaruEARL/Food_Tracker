// lib/screens/driver/driver_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_tab_bar.dart';
import 'bottom_sheets/order_details_bottom_sheet.dart';

class DriverDashboardPage extends StatefulWidget {
  final List<Order> availableOrders;
  final List<Order> activeOrders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int orderId, String status) onUpdateOrderStatus;
  final bool hasActiveOrders;

  const DriverDashboardPage({
    super.key,
    required this.availableOrders,
    required this.activeOrders,
    required this.isLoading,
    required this.onRefresh,
    required this.onUpdateOrderStatus,
    this.hasActiveOrders = false,

  });

  @override
  DriverDashboardPageState createState() => DriverDashboardPageState();
}

class DriverDashboardPageState extends State<DriverDashboardPage>
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
              padding: EdgeInsets.symmetric( vertical: 5),
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
                              'Driver Dashboard',
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'hind',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Icon(FontAwesomeIcons.search, size: 20,color:  Color(0xFFA6A6A6),),
                                  ),

                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          _getCurrentDateTitle(),
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

  String _getCurrentDateTitle() {
    final now = DateTime.now();

    final dayFormatter = DateFormat('EEEE');
    final monthDayFormatter = DateFormat('MMMM d');
    final yearFormatter = DateFormat('y');
    final timeFormatter = DateFormat('hh:mm a');

    return '${dayFormatter.format(now)}, ${monthDayFormatter.format(now)}, ${yearFormatter.format(now)}, ${timeFormatter.format(now)}';
  }


  void _showOrderDetails(Order order, bool isActiveOrder,) {
    OrderDetailsBottomSheet.show(
      context,
      order: order,
      isActiveOrder: isActiveOrder,
      onUpdateOrderStatus: widget.onUpdateOrderStatus,
      hasActiveOrders: widget.activeOrders.isNotEmpty,

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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrderActionButton(
                  isActiveOrder: isActiveOrder,
                  orderId: order.id,
                  onUpdateOrderStatus: widget.onUpdateOrderStatus,
                  hasActiveOrders: widget.activeOrders.isNotEmpty,
                ),

                SizedBox(width: 5,),
                Icon(Icons.keyboard_arrow_right,color: Color(0XFFA49E9E),)
              ],
            ),
            isThreeLine: false,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableOrdersTab() {
    return widget.isLoading
        ? Center()
        : RefreshIndicator(
      color: Color(0xFF0386D0),
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

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.activeOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(widget.activeOrders[index], true);
      },
    );
    }
  }

  Widget _buildDeliveryMapTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            'Delivery Map To be Implemented',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
