import 'package:flutter/material.dart';

class ShimmerProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            color: Colors.grey.shade300,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 16, color: Colors.grey.shade300),
                SizedBox(height: 4),
                Container(width: 60, height: 12, color: Colors.grey.shade300),
                SizedBox(height: 8),
                Container(width: 80, height: 14, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}