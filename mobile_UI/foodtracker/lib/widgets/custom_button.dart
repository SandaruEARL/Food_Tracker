import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class OrderActionButton extends StatefulWidget {
  final bool isActiveOrder;
  final int orderId;
  final Function(int, String) onUpdateOrderStatus;

  const OrderActionButton({
    super.key,
    required this.isActiveOrder,
    required this.orderId,
    required this.onUpdateOrderStatus,
  });

  @override
  State<OrderActionButton> createState() => _OrderActionButtonState();
}

class _OrderActionButtonState extends State<OrderActionButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);

    // Simulate network delay / API call
    await Future.delayed(const Duration(seconds: 2));

    if (widget.isActiveOrder) {
      widget.onUpdateOrderStatus(widget.orderId, OrderStatus.delivered);
    } else {
      widget.onUpdateOrderStatus(widget.orderId, OrderStatus.pickedUp);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActiveOrder ? const Color(0xFFD2A146) : Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            widget.isActiveOrder ? 'Mark Delivered' : 'Approve',
            key: ValueKey(widget.isActiveOrder),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
