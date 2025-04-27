import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  void _addToCart(BuildContext context) {
    // Simulate adding to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.productName} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: product.images.isNotEmpty
                ? Image.network(product.images[0], fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.productName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                ),
                SizedBox(height: 8),
                // Add to Cart Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _addToCart(context),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart, size: 20, color: Colors.blue.shade700),
                          SizedBox(width: 4),
                          Icon(Icons.add_circle, size: 20, color: Colors.blue.shade700),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}