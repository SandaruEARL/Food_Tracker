// lib/screens/driver/driver_profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DriverProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Stack(
      children: [
        // Fixed Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Driver Profile',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'hind',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable Content
        Positioned(
          top: 70, // Adjust based on header height
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  // Driver Information Card
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Driver Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sandaru',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sandaru@speedman.lk',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Vehicle Information Section
                  Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildVehicleInfoItem('Type', 'Scooter'),
                            ),
                            Expanded(
                              child: _buildVehicleInfoItem('Plate', 'WV - 2354'),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildVehicleInfoItem('Insurance valid till', 'December 31, 2025'),
                            ),
                            Expanded(
                              child: _buildVehicleInfoItem('Vehicle Registration', 'December 31, 2024'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Driver Rating Section
                  Text(
                    'Driver rating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:Color(0xFFF6F5F5),
                      borderRadius: BorderRadius.circular(10),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Star Rating
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < 4 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 24,
                                );
                              }),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '4.5/5',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '98% positive feedback',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),


                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}