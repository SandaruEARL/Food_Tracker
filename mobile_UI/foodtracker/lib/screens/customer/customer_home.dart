// lib/screens/customer/customer_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../models/order.dart';
import '../../models/location.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final _descriptionController = TextEditingController();
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.webSocketService.onOrderUpdate = (order) {
      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = order;
        }
      });
    };
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _apiService.getRelevantOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _placeOrder() async {
    if (_descriptionController.text.trim().isEmpty) return;

    final location = await _locationService.getCurrentLocation();
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get your location')),
      );
      return;
    }

    final success = await _apiService.placeOrder(
      _descriptionController.text.trim(),
      location.lat,
      location.lng,
      'Current Location', // You can implement address lookup
    );

    if (success) {
      _descriptionController.clear();
      _loadOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
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
      body: Column(
        children: [
          // Order Placement Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Place New Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'What would you like to order?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _placeOrder,
                    child: Text('Place Order'),
                  ),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text('Order #${order.id}'),
                      subtitle: Text('Status: ${order.status}\nTotal: \$${order.total.toStringAsFixed(2)}'),
                      trailing: _getStatusIcon(order.status),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'NEW':
        return Icon(Icons.schedule, color: Colors.orange);
      case 'ACCEPTED':
        return Icon(Icons.restaurant, color: Colors.blue);
      case 'READY_FOR_PICKUP':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'PICKED_UP':
        return Icon(Icons.local_shipping, color: Colors.purple);
      case 'DELIVERED':
        return Icon(Icons.done_all, color: Colors.green);
      default:
        return Icon(Icons.help);
    }
  }
}