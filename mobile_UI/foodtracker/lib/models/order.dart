// lib/models/order.dart
class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}

class Order {
  final int id;
  final int customerId;
  final int? restaurantId;
  final int? driverId;
  final String status;
  final double total;
  final List<OrderItem>? items;
  final DateTime? createdAt;
  final String? description;

  Order({
    required this.id,
    required this.customerId,
    this.restaurantId,
    this.driverId,
    required this.status,
    required this.total,
    this.items,
    this.createdAt,
    this.description,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      restaurantId: json['restaurantId'],
      driverId: json['driverId'],
      status: json['status'],
      total: (json['total'] as num).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'driverId': driverId,
      'status': status,
      'total': total,
      'items': items?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
    };
  }
}