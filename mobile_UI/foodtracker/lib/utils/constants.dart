// lib/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://192.168.43.10:8080'; // machine's ip address that back-end running
  static const String wsUrl = 'ws://192.168.43.10:8080/ws/websocket'; // For Websocket connection
}

class UserType {
  static const String customer = 'CUSTOMER';
  static const String driver = 'DRIVER';
  static const String restaurant = 'RESTAURANT';
}

class OrderStatus {
  static const String newOrder = 'NEW';
  static const String accepted = 'ACCEPTED';
  static const String readyForPickup = 'READY_FOR_PICKUP';
  static const String pickedUp = 'PICKED_UP';
  static const String delivered = 'DELIVERED';
}
