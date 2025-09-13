import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart' show StompFrame, StompClient, StompConfig;

import '../models/user.dart';
import '../models/order.dart';
import '../models/location.dart';
import '../utils/constants.dart';


class WebSocketService {
  StompClient? _stompClient;
  bool _isConnected = false;

  // Callbacks for different update types
  Function(Order)? onOrderUpdate;
  Function(Location)? onLocationUpdate;
  Function(List<Order>)? onNewOrdersAvailable;

  Future<void> connect(User user) async {
    if (_isConnected) return;

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (StompFrame frame) {
          if (kDebugMode) {
            print('WebSocket connected');
          }
          _isConnected = true;
          _subscribeToTopics(user);
        },
        onDisconnect: (StompFrame frame) {
          if (kDebugMode) {
            print('WebSocket disconnected');
          }
          _isConnected = false;
        },
        onWebSocketError: (dynamic error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
        },
        onStompError: (StompFrame frame) {
          if (kDebugMode) {
            print('STOMP error: ${frame.body}');
          }
        },
      ),
    );

    _stompClient?.activate();
  }

  void _subscribeToTopics(User user) {
    if (!_isConnected || _stompClient == null) return;

    switch (user.type) {
      case UserType.customer:
      // Subscribe to order status updates
        _stompClient!.subscribe(
          destination: '/topic/orders/CUSTOMER/${user.id}',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final orderData = jsonDecode(frame.body!);
              final order = Order.fromJson(orderData);
              onOrderUpdate?.call(order);
            }
          },
        );

        // Subscribe to driver location updates
        _stompClient!.subscribe(
          destination: '/topic/orders/CUSTOMER/location/${user.id}',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final locationData = jsonDecode(frame.body!);
              final location = Location.fromJson(locationData);
              onLocationUpdate?.call(location);
            }
          },
        );
        break;

      case UserType.restaurant:
      // Subscribe to new orders and status updates
        _stompClient!.subscribe(
          destination: '/topic/orders/RESTAURANT',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final data = jsonDecode(frame.body!);
              if (data is List) {
                final orders = data.map((json) => Order.fromJson(json)).toList();
                onNewOrdersAvailable?.call(orders);
              } else {
                final order = Order.fromJson(data);
                onOrderUpdate?.call(order);
              }
            }
          },
        );
        break;

      case UserType.driver:
      // Subscribe to pickup-ready orders
        _stompClient!.subscribe(
          destination: '/topic/orders/DRIVER',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final data = jsonDecode(frame.body!);
              if (data is List) {
                final orders = data.map((json) => Order.fromJson(json)).toList();
                onNewOrdersAvailable?.call(orders);
              } else {
                final order = Order.fromJson(data);
                onOrderUpdate?.call(order);
              }
            }
          },
        );
        break;
    }
  }

  // Send driver location (for drivers when they pick up an order)
  void sendDriverLocation(int orderId, double lat, double lng) {
    if (!_isConnected || _stompClient == null) return;

    _stompClient!.send(
      destination: '/app/driverLocation',
      body: jsonEncode({
        'orderId': orderId,
        'lat': lat,
        'lng': lng,
      }),
    );
  }

  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _isConnected = false;
    }
  }

  bool get isConnected => _isConnected;
}