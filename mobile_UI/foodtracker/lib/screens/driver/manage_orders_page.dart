// lib/screens/driver/manage_orders_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/custom_button.dart';
import 'bottom_sheets/order_details_bottom_sheet.dart';
import 'bottom_sheets/completed_order_details_sheet.dart';

class ManageOrdersPage extends StatefulWidget {
  final List<Order> myOrders;
  final List<Order> activeOrders;
  final List<Order> availableOrders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int orderId, String status) onUpdateOrderStatus;

  const ManageOrdersPage({
    super.key,
    required this.myOrders,
    required this.activeOrders,
    required this.availableOrders,
    required this.isLoading,
    required this.onRefresh,
    required this.onUpdateOrderStatus,
  });

  @override
  ManageOrdersPageState createState() => ManageOrdersPageState();
}

class ManageOrdersPageState extends State<ManageOrdersPage>
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
      case 0:
        return widget.availableOrders;
      case 1:
        return widget.myOrders
            .where((order) => order.status == OrderStatus.readyForPickup)
            .toList();
      case 2:
        return widget.myOrders
            .where((order) => order.status == OrderStatus.pickedUp)
            .toList();
      case 3:
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
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Icon(FontAwesomeIcons.search, size: 20,color:  Color(0xFFA6A6A6),),
                                  ),
                                  SizedBox(width: 10,),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Icon(FontAwesomeIcons.locationCrosshairs, size: 20, color:  Color(0xFFA6A6A6),),
                                  ),
                                  SizedBox(width: 10,),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Icon(FontAwesomeIcons.sync, size: 20, color:  Color(0xFFA6A6A6),),
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
      'All(${widget.availableOrders.length})',
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
      child:ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          if (tabIndex == 3) {
            return _buildCompletedOrderCard(filteredOrders[index]);
          } else {
            bool isActiveOrder = tabIndex == 2;
            return _buildOrderCard(filteredOrders[index], isActiveOrder);
          }
        },
      ),
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


  void _showOrderDetails(Order order, bool isActiveOrder) {
    OrderDetailsBottomSheet.show(
      context,
      order: order,
      isActiveOrder: isActiveOrder,
      onUpdateOrderStatus: widget.onUpdateOrderStatus,
      hasActiveOrders: _getFilteredOrders(2).isNotEmpty,
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
}