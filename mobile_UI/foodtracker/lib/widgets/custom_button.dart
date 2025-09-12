import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class OrderActionButton extends StatefulWidget {
  final bool isActiveOrder;
  final int orderId;
  final Function(int, String) onUpdateOrderStatus;
  final bool hasActiveOrders;
  final VoidCallback? onActionComplete;

  const OrderActionButton({
    super.key,
    required this.isActiveOrder,
    required this.orderId,
    required this.onUpdateOrderStatus,
    this.hasActiveOrders = false,
    this.onActionComplete,
  });

  @override
  State<OrderActionButton> createState() => _OrderActionButtonState();
}

class _OrderActionButtonState extends State<OrderActionButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    // Don't allow action if button is disabled
    if (_isButtonDisabled()) return;

    setState(() => _isLoading = true);

    // Simulate network delay / API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.isActiveOrder) {
      widget.onUpdateOrderStatus(widget.orderId, OrderStatus.delivered);
    } else {
      widget.onUpdateOrderStatus(widget.orderId, OrderStatus.pickedUp);
    }

    setState(() => _isLoading = false);

    // Call the completion callback if provided
    widget.onActionComplete?.call();
  }

  bool _isButtonDisabled() {
    // Disable approve buttons when there are active orders
    return !widget.isActiveOrder && widget.hasActiveOrders;
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = _isButtonDisabled();

    return GestureDetector(
      onTap: (_isLoading || isDisabled) ? null : _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[400] // Disabled color
              : widget.isActiveOrder
              ? const Color(0xFFD2A146)
              : Colors.green,
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
            widget.isActiveOrder ? 'Mark Delivered' : 'Accept',
            key: ValueKey(widget.isActiveOrder),
            style: TextStyle(
              color: isDisabled ? Colors.grey[600] : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}