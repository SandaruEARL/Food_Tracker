// lib/screens/driver/driver_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../models/order.dart';
import '../../utils/constant.dart';


class DriverHome extends StatefulWidget {
  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  List<Order> _availableOrders = [];
  List<Order> _myOrders = [];
  bool _isLoading = false;
  int _currentIndex = 0;

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
      setState(() => _availableOrders = orders);
    };
  }

  void _setupLocationTracking() {
    _locationService.onLocationUpdate = (location) {
      // Send location to WebSocket if driver is on active delivery
      final activeOrder = _myOrders.where((o) => o.status == OrderStatus.pickedUp).firstOrNull;
      if (activeOrder != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.webSocketService.sendDriverLocation(
            activeOrder.id,
            location.lat,
            location.lng
        );
      }
    };
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final available = await _apiService.getAvailableOrdersDriver();
    final relevant = await _apiService.getRelevantOrders();
    setState(() {
      _availableOrders = available;
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
        title: Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildAvailableOrdersTab(),
          _buildMyOrdersTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _availableOrders.length,
        itemBuilder: (context, index) {
          final order = _availableOrders[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Order #${order.id}'),
              subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
              trailing: ElevatedButton(
                onPressed: () => _updateOrderStatus(order.id, OrderStatus.pickedUp),
                child: Text('Pick Up'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyOrdersTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _myOrders.length,
        itemBuilder: (context, index) {
          final order = _myOrders[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Order #${order.id}'),
              subtitle: Text('Status: ${order.status}\nTotal: \$${order.total.toStringAsFixed(2)}'),
              trailing: _getActionButton(order),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget? _getActionButton(Order order) {
    switch (order.status) {
      case OrderStatus.pickedUp:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.delivered),
          child: Text('Deliver'),
        );
      default:
        return null;
    }
  }
}