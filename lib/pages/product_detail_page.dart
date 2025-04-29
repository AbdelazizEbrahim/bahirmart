import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:carousel_slider/carousel_slider.dart' as carousel hide CarouselController;
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final prod_model.Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review comment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      // TODO: Replace with actual API call
      // final review = {
      //   'customerId': 'current_user_id',
      //   'comment': _reviewController.text,
      //   'rating': _rating,
      //   'createdDate': DateTime.now(),
      // };
      // await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}/products/${widget.product.id}/reviews'),
      //   body: jsonEncode(review),
      // );

      setState(() {
        _isSubmitting = false;
        _reviewController.clear();
        _rating = 5.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: BahirMartAppBar(title: widget.product.productName),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Carousel
                    if (widget.product.images.isNotEmpty)
                      carousel.CarouselSlider(
                        options: carousel.CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                        ),
                        items: widget.product.images.map((imageUrl) {
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          );
                        }).toList(),
                      )
                    else
                      Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.productName,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              Text(
                                currencyFormat.format(widget.product.price),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Merchant Info
                          Row(
                            children: [
                              const Icon(Icons.store, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.merchantDetail.merchantName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category and Brand
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.category,
                                widget.product.category.categoryName,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.branding_watermark,
                                widget.product.brand,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Delivery Info
                          _buildInfoRow(
                            'Delivery',
                            '${widget.product.delivery} - ${currencyFormat.format(widget.product.deliveryPrice)}',
                          ),
                          const SizedBox(height: 8),

                          // Stock Info
                          _buildInfoRow(
                            'Stock',
                            '${widget.product.quantity} available',
                          ),
                          const SizedBox(height: 8),

                          // Sold Info
                          _buildInfoRow(
                            'Sold',
                            '${widget.product.soldQuantity} units',
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),

                          // Variants and Sizes
                          if (widget.product.variant.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Variants',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.product.variant
                                      .map((variant) => Chip(label: Text(variant)))
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          if (widget.product.size.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sizes',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.product.size
                                      .map((size) => Chip(label: Text(size)))
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Reviews Section
                          Text(
                            'Reviews',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // Average Rating
                          if (widget.product.review.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  (widget.product.review.map((r) => r.rating).reduce((a, b) => a + b) /
                                          widget.product.review.length)
                                      .toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                _buildRatingStars(
                                  widget.product.review.map((r) => r.rating).reduce((a, b) => a + b) /
                                      widget.product.review.length,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${widget.product.review.length} reviews)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          else
                            const Text('No reviews yet'),
                          const SizedBox(height: 16),

                          // Review List
                          if (widget.product.review.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.product.review.length,
                              itemBuilder: (context, index) {
                                final review = widget.product.review[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildRatingStars(review.rating as double),
                                            Text(
                                              dateFormat.format(review.createdDate),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            const Center(
                              child: Text('Be the first to review this product!'),
                            ),
                          const SizedBox(height: 16),

                          // Add Review Section
                          Text(
                            'Add a Review',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Rating: '),
                              Expanded(
                                child: Slider(
                                  value: _rating,
                                  min: 1,
                                  max: 5,
                                  divisions: 8,
                                  label: _rating.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setState(() {
                                      _rating = value;
                                    });
                                  },
                                ),
                              ),
                              Text(_rating.toStringAsFixed(1)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Write your review here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitReview,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Submit Review'),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add to cart functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Buy now functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Proceeding to checkout')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating.ceil() && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }
}
