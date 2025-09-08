// lib/screens/restaurant/restaurant_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';


class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  _RestaurantHomeState createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final ApiService _apiService = ApiService();
  List<Order> _newOrders = [];
  List<Order> _myOrders = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebSocketListeners();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Dashboard'),
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
          _buildNewOrdersTab(),
          _buildMyOrdersTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            label: 'New Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrdersTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _newOrders.length,
        itemBuilder: (context, index) {
          final order = _newOrders[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  if (order.items != null) ...[
                    Text('Items:'),
                    ...order.items!.map((item) => Text('- ${item.name} x${item.quantity}')),
                  ],
                  SizedBox(height: 8),
                  Text('Total: \$${order.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateOrderStatus(order.id, OrderStatus.accepted),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text('Accept'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Handle reject - might want to implement a reject API
                        },
                        child: Text('Reject'),
                      ),
                    ],
                  ),
                ],
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
      case OrderStatus.accepted:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.readyForPickup),
          child: Text('Ready'),
        );
      default:
        return null;
    }
  }
}