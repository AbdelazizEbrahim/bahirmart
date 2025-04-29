import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bahirmart/core/models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  int get itemCount => _items.length;
  
  // Calculate subtotal (product price * quantity)
  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }
  
  // Calculate total delivery cost
  double get deliveryCost {
    return _items.fold(0, (sum, item) => sum + item.product.calculateDeliveryCost(item.quantity));
  }
  
  // Calculate total amount including delivery
  double get totalAmount {
    return subtotal + deliveryCost;
  }
  
  CartService() {
    _loadCart();
  }
  
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    
    if (cartJson != null) {
      final List<dynamic> cartData = json.decode(cartJson);
      _items = cartData.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }
  
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }
  
  Future<void> addItem(Product product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Item already exists, update quantity
      _items[existingIndex] = CartItem(
        product: product,
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    await _saveCart();
    notifyListeners();
  }
  
  Future<void> removeItem(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }
  
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = CartItem(
        product: _items[index].product,
        quantity: quantity,
      );
      await _saveCart();
      notifyListeners();
    }
  }
  
  Future<void> clearCart() async {
    _items = [];
    await _saveCart();
    notifyListeners();
  }
  
  // Get items grouped by merchant
  Map<String, List<CartItem>> getItemsByMerchant() {
    final Map<String, List<CartItem>> merchantGroups = {};
    
    for (final item in _items) {
      final merchantId = item.product.merchantDetail.merchantId;
      if (!merchantGroups.containsKey(merchantId)) {
        merchantGroups[merchantId] = [];
      }
      merchantGroups[merchantId]!.add(item);
    }
    
    return merchantGroups;
  }
  
  // Get subtotal for a specific merchant
  double getMerchantSubtotal(String merchantId) {
    final merchantItems = _items.where((item) => item.product.merchantDetail.merchantId == merchantId).toList();
    return merchantItems.fold(0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }
  
  // Get delivery cost for a specific merchant
  double getMerchantDeliveryCost(String merchantId) {
    final merchantItems = _items.where((item) => item.product.merchantDetail.merchantId == merchantId).toList();
    return merchantItems.fold(0, (sum, item) => sum + item.product.calculateDeliveryCost(item.quantity));
  }
  
  // Get total amount for a specific merchant
  double getMerchantTotal(String merchantId) {
    return getMerchantSubtotal(merchantId) + getMerchantDeliveryCost(merchantId);
  }
}

class CartItem {
  final Product product;
  final int quantity;
  
  CartItem({
    required this.product,
    required this.quantity,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
  
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
} 