// lib/screens/restaurant/restaurant_home.dart
import 'package:flutter/material.dart';
import 'package:foodtracker/screens/restaurant/retaurent_summery_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/custom_tab_bar.dart';
import 'package:intl/intl.dart';

import 'add_menu_bottom_sheet.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override RestaurantHomeState createState() => RestaurantHomeState();
}

class RestaurantHomeState extends State<RestaurantHome> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Order> _newOrders = [];
  List<Order> _myOrders = [];
  bool _isLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _setupWebSocketListeners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupWebSocketListeners() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.webSocketService.onNewOrdersAvailable = (orders) {
      setState(() => _newOrders = orders);
    };
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final newOrders = await _apiService.getAvailableOrdersRestaurant();
    final myOrders = await _apiService.getRelevantOrders();
    setState(() {
      _newOrders = newOrders;
      _myOrders = myOrders;
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final success = await _apiService.updateOrderStatus(orderId, status);
    if (success) {
      _loadOrders();
    }
  }

  void _showSummaryBottomSheet() {
    RestaurantSummaryBottomSheet.show(context, _newOrders, _myOrders, );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            BrandLogo(size: 20,),
          ],
        ),
        centerTitle: false,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              GestureDetector(
                onTap: _showSummaryBottomSheet,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFA6A6A6),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'hind',
                        color: Color(0xFF0386D0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.logout, color: Color(0xFFA6A6A6)),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await authProvider.logout();
                navigator.pushReplacementNamed('/');
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableOrdersTab(),
                _buildMyOrdersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddMenuItemBottomSheet.show(context);
        },
        backgroundColor: const Color(0xFF0386D0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric( vertical: 5),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Manage Restaurant',
                              style: TextStyle(
                                fontSize: 25,
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
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          CustomTabBar(
            controller: _tabController,
            tabTitles: [
              'Available Orders(${_newOrders.length})',
              'My Orders(${_myOrders.length})'
            ],
            margin: EdgeInsets.zero,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
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

  Widget _buildAvailableOrdersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _newOrders.length,
              itemBuilder: (context, index) {
                final order = _newOrders[index];
                return _buildOrderCard(order, isAvailable: true);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyOrdersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myOrders.length,
              itemBuilder: (context, index) {
                final order = _myOrders[index];
                return _buildOrderCard(order, isAvailable: false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order, {required bool isAvailable}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF6F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Handle order tap if needed
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              '#ORD-${order.id.toString().padLeft(5, '0')}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  order.items?.first.name ?? 'Order Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(order.id, OrderStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0386D0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mark Prepare',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                else
                  _getActionButton(order) ?? const SizedBox.shrink(),
                SizedBox(width: 5,),
                Icon(Icons.keyboard_arrow_right, color: Color(0XFFA49E9E),)
              ],
            ),
            isThreeLine: false,
          ),
        ),
      ),
    );
  }

  Widget? _getActionButton(Order order) {
    switch (order.status) {
      case OrderStatus.accepted:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.readyForPickup),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0386D0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Ready',
            style: TextStyle(fontSize: 12),
          ),
        );
      default:
        return null;
    }
  }
}