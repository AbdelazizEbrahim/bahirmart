import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/product_model.dart';
import 'package:bahirmart/core/services/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(title: 'Shopping Cart'),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your cart to proceed with checkout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          // Get items grouped by merchant
          final merchantGroups = cartService.getItemsByMerchant();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: merchantGroups.length,
                  itemBuilder: (context, index) {
                    final merchantId = merchantGroups.keys.elementAt(index);
                    final merchantItems = merchantGroups[merchantId]!;
                    final merchant = merchantItems.first.product.merchantDetail;
                    
                    // Get merchant-specific totals
                    final subtotal = cartService.getMerchantSubtotal(merchantId);
                    final deliveryCost = cartService.getMerchantDeliveryCost(merchantId);
                    final total = cartService.getMerchantTotal(merchantId);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Merchant header
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingMedium),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    merchant.merchantName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        merchant.merchantName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${merchantItems.length} item${merchantItems.length > 1 ? 's' : ''}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Products list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: merchantItems.length,
                            itemBuilder: (context, itemIndex) {
                              final item = merchantItems[itemIndex];
                              return CartItemTile(item: item);
                            },
                          ),
                          
                          // Merchant summary
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingMedium),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '\$${subtotal.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '\$${deliveryCost.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Checkout button
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Amount',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '\$${cartService.totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to checkout page
                            Navigator.pushNamed(context, '/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 2),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<CartService>(context, listen: false).removeItem(item.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.productName} removed from cart'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                Provider.of<CartService>(context, listen: false).addItem(item.product, quantity: item.quantity);
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.images.isNotEmpty ? item.product.images[0] : 'https://via.placeholder.com/100',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Row(
                    children: [
                      if (item.product.hasActiveOffer)
                        Text(
                          '\$${item.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                        ),
                      if (item.product.hasActiveOffer)
                        const SizedBox(width: 8),
                      Text(
                        '\$${item.product.currentPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Delivery info
                  Text(
                    'Delivery: ${_getDeliveryInfo(item.product)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  
                  // Quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (item.quantity > 1) {
                                Provider.of<CartService>(context, listen: false)
                                    .updateQuantity(item.product.id, item.quantity - 1);
                              }
                            },
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (item.quantity < item.product.quantity) {
                                Provider.of<CartService>(context, listen: false)
                                    .updateQuantity(item.product.id, item.quantity + 1);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Maximum quantity reached'),
                                  ),
                                );
                              }
                            },
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        '\$${(item.product.currentPrice * item.quantity).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDeliveryInfo(Product product) {
    switch (product.delivery) {
      case 'PERPIECE':
        return 'Per piece (\$${product.deliveryPrice.toStringAsFixed(2)} each)';
      case 'PERKG':
        return 'Per kg (\$${product.kilogramPerPrice?.toStringAsFixed(2) ?? product.deliveryPrice.toStringAsFixed(2)} per kg)';
      case 'PERKM':
        return 'Per km (\$${product.kilometerPerPrice?.toStringAsFixed(2) ?? product.deliveryPrice.toStringAsFixed(2)} per km)';
      case 'FREE':
        return 'Free delivery';
      default:
        return 'Standard delivery (\$${product.deliveryPrice.toStringAsFixed(2)})';
    }
  }
}
