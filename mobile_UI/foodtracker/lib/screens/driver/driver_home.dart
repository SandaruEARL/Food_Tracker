// lib/screens/driver/driver_home.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodtracker/widgets/brand_logo.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';

import 'bottom_sheets/completed_orders_bottom_sheet.dart';
import 'driver_dashboard_page.dart';
import 'driver_profile.dart';
import 'manage_orders_page.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  DriverHomeState createState() => DriverHomeState();
}

class DriverHomeState extends State<DriverHome> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  List<Order> _availableOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _myOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = false;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebSocketListeners();
    _setupLocationTracking();
  }

  void _setupWebSocketListeners() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.webSocketService.onNewOrdersAvailable = (orders) {
      setState(() {
        _availableOrders = orders.where((o) => o.status == OrderStatus.readyForPickup).toList();
        _activeOrders = orders.where((o) => o.status == OrderStatus.pickedUp).toList();
      });
    };
  }

  void _setupLocationTracking() {
    _locationService.onLocationUpdate = (location) {
      final activeOrder = _activeOrders.firstWhere(
            (o) => o.status == OrderStatus.pickedUp,
        orElse: () => null as Order,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.webSocketService.sendDriverLocation(
          activeOrder.id,
          location.lat,
          location.lng
      );
        };
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final available = await _apiService.getAvailableOrdersDriver();
    final relevant = await _apiService.getRelevantOrders();
    setState(() {
      _availableOrders = available.where((o) => o.status == OrderStatus.readyForPickup).toList();
      _activeOrders = relevant.where((o) => o.status == OrderStatus.pickedUp).toList();
      _completedOrders = relevant.where((o) => o.status == OrderStatus.delivered).toList();
      _myOrders = relevant;
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final success = await _apiService.updateOrderStatus(orderId, status);
    if (success) {
      if (status == OrderStatus.pickedUp) {
        _locationService.startLocationTracking();
      } else if (status == OrderStatus.delivered) {
        _locationService.stopLocationTracking();
      }
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            BrandLogo(size: 20,),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  CompletedOrdersBottomSheet.show(
                    context,
                    completedOrders: _completedOrders,
                    isLoading: _isLoading,
                    onRefresh: _loadOrders,
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFA6A6A6),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
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
                await authProvider.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ),
        ],
        //Set explicit colors and elevation
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0, // A trick for to prevent on-scroll color change on the app bar
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          DriverDashboardPage(
            availableOrders: _availableOrders,
            activeOrders: _activeOrders,
            isLoading: _isLoading,
            onRefresh: _loadOrders,
            onUpdateOrderStatus: _updateOrderStatus,
          ),
          ManageOrdersPage(
            myOrders: _myOrders,
            isLoading: _isLoading,
            onRefresh: _loadOrders,
            activeOrders: _activeOrders,
            availableOrders: _availableOrders,
            onUpdateOrderStatus: _updateOrderStatus,
          ),
          DriverProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) => setState(() => _currentPageIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0386D0),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white, // consistent bottom navigation color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.truck),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}