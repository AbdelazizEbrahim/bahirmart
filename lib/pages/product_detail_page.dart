import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:carousel_slider/carousel_slider.dart' as carousel hide CarouselController;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/main.dart';
import 'package:bahirmart/core/services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final prod_model.Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _rating = 5.0;
  bool _isSubmitting = false;
  bool _hasUserReviewed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _checkUserReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkUserReview() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _hasUserReviewed = widget.product.review.any((review) => review.customerId == user.id);
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a review comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}/products/${widget.product.id}/reviews'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer ${user.token}',
      //   },
      //   body: jsonEncode({
      //     'customerId': user.id,
      //     'comment': _reviewController.text,
      //     'rating': _rating,
      //     'createdDate': DateTime.now().toIso8601String(),
      //   }),
      // );

      // if (response.statusCode == 201) {
      //   final newReview = prod_model.Review.fromJson(jsonDecode(response.body));
      //   setState(() {
      //     widget.product.review.add(newReview);
      //     _hasUserReviewed = true;
      //   });
      // }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isSubmitting = false;
        _reviewController.clear();
        _rating = 5.0;
        _hasUserReviewed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: BahirMartAppBar(title: widget.product.productName),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                            enlargeCenterPage: true,
                          ),
                          items: widget.product.images.map((imageUrl) {
                            return Hero(
                              tag: 'product_${widget.product.id}',
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
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
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (widget.product.hasActiveOffer)
                                      Text(
                                        currencyFormat.format(widget.product.price),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        currencyFormat.format(widget.product.currentPrice),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (widget.product.hasActiveOffer)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${widget.product.discountPercentage.toStringAsFixed(0)}% OFF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Merchant Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.store, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sold by',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          widget.product.merchantDetail.merchantName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Category and Brand
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.category,
                                    widget.product.category.categoryName,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.branding_watermark,
                                    widget.product.brand,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Delivery Info
                            _buildInfoCard(
                              'Delivery Information',
                              [
                                _buildInfoRow(
                                  'Type',
                                  widget.product.delivery,
                                  Icons.local_shipping,
                                ),
                                _buildInfoRow(
                                  'Price',
                                  currencyFormat.format(widget.product.deliveryPrice),
                                  Icons.attach_money,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Stock Info
                            _buildInfoCard(
                              'Stock Information',
                              [
                                _buildInfoRow(
                                  'Available',
                                  '${widget.product.quantity} units',
                                  Icons.inventory_2,
                                ),
                                _buildInfoRow(
                                  'Sold',
                                  '${widget.product.soldQuantity} units',
                                  Icons.shopping_cart,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildSectionTitle('Description'),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.product.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Variants and Sizes
                            if (widget.product.variant.isNotEmpty) ...[
                              _buildSectionTitle('Variants'),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.product.variant
                                      .map((variant) => Chip(
                                            label: Text(variant),
                                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (widget.product.size.isNotEmpty) ...[
                              _buildSectionTitle('Sizes'),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.product.size
                                      .map((size) => Chip(
                                            label: Text(size),
                                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Reviews Section
                            _buildSectionTitle('Reviews'),
                            if (widget.product.review.isNotEmpty)
                              Column(
                                children: [
                                  // Average Rating
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          (widget.product.review.map((r) => r.rating).reduce((a, b) => a + b) /
                                                  widget.product.review.length)
                                              .toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildRatingStars(
                                              widget.product.review.map((r) => r.rating).reduce((a, b) => a + b) /
                                                  widget.product.review.length,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${widget.product.review.length} reviews',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Review List
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: widget.product.review.length,
                                    itemBuilder: (context, index) {
                                      final review = widget.product.review[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _buildRatingStars(review.rating.toDouble()),
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
                                  ),
                                ],
                              )
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Be the first to review this product!',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Add Review Section
                            if (user != null && !_hasUserReviewed) ...[
                              _buildSectionTitle('Add a Review'),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _rating.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _reviewController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Write your review here...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting ? null : _submitReview,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
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
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    child: Consumer<CartService>(
                      builder: (context, cartService, child) {
                        final isInCart = cartService.items.any((item) => item.product.id == widget.product.id);
                        
                        return ElevatedButton(
                          onPressed: () {
                            if (isInCart) {
                              Navigator.pushNamed(context, '/cart');
                            } else {
                              cartService.addItem(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.product.productName} added to cart'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/cart');
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isInCart ? 'View Cart' : 'Add to Cart'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart and proceed to checkout
                        final cartService = Provider.of<CartService>(context, listen: false);
                        cartService.addItem(widget.product);
                        
                        // Navigate to checkout
                        Navigator.pushNamed(context, '/checkout');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < rating.ceil() && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
}
