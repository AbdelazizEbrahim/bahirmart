import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/image_carousel.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Carousel
            ImageCarousel(images: product.images),
            // Main Details
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, color: Colors.blue.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Category: ${product.category.categoryName}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  if (product.variant.isNotEmpty)
                    Text(
                      'Variants: ${product.variant.join(', ')}',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (product.size.isNotEmpty)
                    Text(
                      'Sizes: ${product.size.join(', ')}',
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 8),
                  Text(
                    'Brand: ${product.brand}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Reviews Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            product.review.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: product.review.length,
                    itemBuilder: (context, index) {
                      final review = product.review[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer ID: ${review.customerId}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < review.rating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(review.comment),
                              SizedBox(height: 4),
                              Text(
                                'Posted on: ${review.createdDate.toLocal().toString().split('.')[0]}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}