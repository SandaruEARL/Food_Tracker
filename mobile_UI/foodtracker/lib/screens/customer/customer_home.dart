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
  final _customerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  // Add the missing controllers
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  List<Order> _orders = [];
  bool _isLoading = false;
  Location? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebSocketListeners();
    _initializeCustomerInfo();
    _getCurrentLocation(); // Get initial location
  }

  void _initializeCustomerInfo() {
    // Initialize with sample data - you can replace this with actual user data
    _customerNameController.text = "John Doe";
    _phoneNumberController.text = "+1 (555) 123-4567";
    _addressController.text = "123 Main St, City, State 12345";
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

  // Add the missing _getCurrentLocation method
  Future<void> _getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
        _latitudeController.text = location.lat.toStringAsFixed(6);
        _longitudeController.text = location.lng.toStringAsFixed(6);
      });
    } else {
      // Show error if location couldn't be retrieved
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get your location. Please check permissions.')),
        );
      }
    }
  }

  // placing the order
  Future<void> _placeOrder() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an order description')),
      );
      return;
    }

    // Use current location or try to get it again
    Location? location = _currentLocation;
    if (location == null) {
      location = await _locationService.getCurrentLocation();
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get your location')),
        );
        return;
      }
    }

    final success = await _apiService.placeOrder(
      _descriptionController.text.trim(),
      location.lat,
      location.lng,
      _addressController.text.trim().isEmpty ? 'Current Location' : _addressController.text.trim(),
    );

    if (success) {
      _descriptionController.clear();
      _specialInstructionsController.clear();
      _loadOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _specialInstructionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
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

                  // 1. Order Description field (editable)
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Order Description',
                      hintText: 'What would you like to order?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12),

                  // 2. Latitude field (disabled - injected from location service)
                  TextField(
                    controller: _latitudeController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Refresh location',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // 3. Longitude field (disabled - injected from location service)
                  TextField(
                    controller: _longitudeController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),

                  // 4. Address field (editable)
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      hintText: 'Enter your delivery address',
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