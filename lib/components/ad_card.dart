import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;
import 'package:go_router/go_router.dart';

class AdCard extends StatefulWidget {
  final ad_model.Ad ad;

  const AdCard({Key? key, required this.ad}) : super(key: key);

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isBuyHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToProductDetail() {
    // Navigate to product detail page
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: widget.ad.product,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: widget.ad.product.images.isNotEmpty ? widget.ad.product.images[0] : 'https://picsum.photos/300/200',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
                  widget.ad.product.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  '\$${widget.ad.product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Buy Button
                SizedBox(
                  height: 36,
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isBuyHovered = true;
                      });
                      _animationController.forward();
                    },
                    onExit: (_) {
                      setState(() {
                        _isBuyHovered = false;
                      });
                      _animationController.reverse();
                    },
                    child: GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      onTap: _navigateToProductDetail,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isBuyHovered ? _scaleAnimation.value : 1.0,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _isBuyHovered
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _navigateToProductDetail,
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.shopping_cart, size: 14),
                                          SizedBox(width: 2),
                                          Text(
                                            'Buy', 
                                            style: TextStyle(
                                              fontSize: 12, 
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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