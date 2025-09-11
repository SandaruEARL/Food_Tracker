// lib/screens/customer/customer_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../models/order.dart';
import '../../models/location.dart';
import '../../widgets/brand_logo.dart';
import 'orders_bottom_sheet.dart';


class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final _descriptionController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isFetchingLocation = false;
  Location? _currentLocation;

  // Animation controller and animation for sync icon
  late AnimationController _rotationAnimationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _rotationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadOrders();
    _setupWebSocketListeners();
    _initializeCustomerInfo();
    // Removed _getCurrentLocation() - only fetch when user taps the sync icon
  }

  void _initializeCustomerInfo() {
    // Set default placeholder values that match the field titles
    _descriptionController.text = "";
    _addressController.text = "";
    _latitudeController.text = "Tap sync icon to get location";
    _longitudeController.text = "Tap sync icon to get location";
    _customerNameController.text = "John Doe";
    _phoneNumberController.text = "+1 (555) 123-4567";
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

  Future<void> _getCurrentLocation() async {
    if (_isFetchingLocation) return; // Prevent multiple simultaneous requests

    setState(() {
      _isFetchingLocation = true;
    });

    // Reset and start rotation animation
    _rotationAnimationController.reset();
    _rotationAnimationController.repeat(); // Use repeat for continuous rotation

    final location = await _locationService.getCurrentLocation();

    // Stop animation
    _rotationAnimationController.stop();
    _rotationAnimationController.reset();

    setState(() {
      _isFetchingLocation = false;
    });

    if (location != null) {
      setState(() {
        _currentLocation = location;
        // Override the default placeholder with actual coordinates
        _latitudeController.text = location.lat.toStringAsFixed(6);
        _longitudeController.text = location.lng.toStringAsFixed(6);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get your location. Please check permissions.')),
        );
        // Reset to placeholder text if location fetch failed
        setState(() {
          _latitudeController.text = "Tap sync icon to get location";
          _longitudeController.text = "Tap sync icon to get location";
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    // Clear default placeholders if they haven't been changed
    String description = _descriptionController.text.trim();
    String address = _addressController.text.trim();

    if (description.isEmpty || description == "Order Description") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an order description')),
      );
      return;
    }

    Location? location = _currentLocation;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please get your location first by tapping the sync icon')),
      );
      return;
    }

    // Use default address if not changed
    String finalAddress = (address.isEmpty || address == "Address")
        ? 'Current Location'
        : address;

    final success = await _apiService.placeOrder(
      description,
      location.lat,
      location.lng,
      finalAddress,
    );

    if (success) {
      _descriptionController.text = "Order Description"; // Reset to placeholder
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

  void _showOrdersBottomSheet() {
    OrdersBottomSheet.show(context);
  }

  @override
  void dispose() {
    _rotationAnimationController.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 19.0),
              child: BrandLogo(
                size: 20,
                showVersion: false,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: _showOrdersBottomSheet,
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFA6A6A6),
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'view orders',
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
            SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.logout, color: Color(0xFFA6A6A6)),
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'hind',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Order Description
              _buildTextField(
                controller: _descriptionController,
                label: '',
                hintText: 'What would you like to order?',
              ),

              // Location Fields with Stacked Sync Icon
              _buildLocationFields(),

              // Address
              _buildTextField(
                controller: _addressController,
                label: '',
                hintText: 'Enter your delivery address',
              ),
              SizedBox(height: 40),

              // Place Order Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0386D0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        // Latitude field with stacked sync icon
        Stack(
          children: [
            _buildTextField(
              controller: _latitudeController,
              label: '',
              enabled: false,
            ),
            // Positioned sync icon
            Positioned(
              right: 25, // Adjust to position within the text field
              top: 35, // Adjust to center vertically within the text field
              child: GestureDetector(
                onTap: _isFetchingLocation ? null : _getCurrentLocation,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) => Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Icon(
                        Icons.sync,
                        color: _isFetchingLocation ? Colors.grey : Color(0xFF0386D0),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Longitude field (without icon)
        _buildTextField(
          controller: _longitudeController,
          label: '',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              onTap: () {
                // Clear placeholder text when user taps on editable fields
                if (enabled) {
                  if (controller.text == label ||
                      (controller == _descriptionController && controller.text == "Order Description") ||
                      (controller == _addressController && controller.text == "Address")) {
                    controller.clear();
                  }
                }
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: suffixIcon,
              ),
              style: TextStyle(
                fontSize: 14,
                color: enabled ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),

      ],
    );
  }
}