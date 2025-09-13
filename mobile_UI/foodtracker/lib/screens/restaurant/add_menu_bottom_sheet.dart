// lib/screens/restaurant/add_menu_item_bottom_sheet.dart
import 'package:flutter/material.dart';

class AddMenuItemBottomSheet extends StatefulWidget {
  const AddMenuItemBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMenuItemBottomSheet(),
    );
  }

  @override
  _AddMenuItemBottomSheetState createState() => _AddMenuItemBottomSheetState();
}

class _AddMenuItemBottomSheetState extends State<AddMenuItemBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _handleAddItem() {
    // Handle add menu item logic here
    print('Item Name: ${_nameController.text}');
    print('Description: ${_descriptionController.text}');
    print('Price: ${_priceController.text}');
    print('Category: ${_categoryController.text}');

    Navigator.of(context).pop();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleImageUpload() {
    // Handle image upload logic here (dummy for now)
    print('Image upload tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0386D0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Menu Item',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'hind',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleCancel,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Item Name Field
                          _buildInputField(
                            controller: _nameController,
                            hintText: 'Item Name',
                          ),

                          const SizedBox(height: 16),

                          // Item Description Field
                          _buildInputField(
                            controller: _descriptionController,
                            hintText: 'Item Description',
                            maxLines: 3,
                          ),

                          const SizedBox(height: 16),

                          // Price Field
                          _buildInputField(
                            controller: _priceController,
                            hintText: 'Price',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),

                          const SizedBox(height: 16),

                          // Category Field
                          _buildInputField(
                            controller: _categoryController,
                            hintText: 'Category',
                          ),

                          const SizedBox(height: 20),

                          // Image Upload Button
                          GestureDetector(
                            onTap: _handleImageUpload,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Image of the item',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontFamily: 'hind',
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Action Buttons
                          Row(
                            children: [
                              // Cancel Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleCancel,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF666666),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'hind',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Add Item Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleAddItem,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0386D0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Add Item',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'hind',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Bottom padding for safe area
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'hind',
          fontSize: 16,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontFamily: 'hind',
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}