import 'dart:convert';
import 'package:bahirmart/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bahirmart/core/models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  // Calculate subtotal (product price * quantity)
  double get subtotal {
    return _items.fold(
        0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }

  // Calculate total delivery cost
  double get deliveryCost {
    return calculateDeliveryCost();
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
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

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
    final merchantItems = _items
        .where((item) => item.product.merchantDetail.merchantId == merchantId)
        .toList();
    return merchantItems.fold(
        0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }

  // Get delivery cost for a specific merchant
  double getMerchantDeliveryCost(String merchantId) {
    final merchantItems = _items
        .where((item) => item.product.merchantDetail.merchantId == merchantId)
        .toList();
    return merchantItems.fold(0,
        (sum, item) => sum + item.product.calculateDeliveryCost(item.quantity));
  }

  // Get total amount for a specific merchant
  double getMerchantTotal(String merchantId) {
    return getMerchantSubtotal(merchantId) +
        getMerchantDeliveryCost(merchantId);
  }

  double calculateDeliveryCost() {
    double totalDeliveryCost = 0;
    for (var item in _items) {
      totalDeliveryCost += item.product.calculateDeliveryCost(item.quantity);
    }
    return totalDeliveryCost;
  }

  Future<void> initializePayment(BuildContext context, double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('Token not found');
        return;
      }

      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (user == null) {
        print('User not loaded in provider');
        return;
      }

      final headers = {
        'Authorization': 'Bearer ${dotenv.env['CHAPA_SECRET_KEY']}',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "amount": amount.toStringAsFixed(2),
        "currency": "ETB",
        "email": user.email,
        "first_name": user.fullName.split(' ').first,
        "last_name": user.fullName.split(' ').length > 1
            ? user.fullName.split(' ').last
            : '',
        "phone_number": "0912345678", // Optional: Replace with actual if stored
        "tx_ref": "chewatatest-${DateTime.now().millisecondsSinceEpoch}",
        "callback_url": "https://webhook.site/your-callback-url",
        "return_url": "https://your-return-url.com/",
        "customization": {
          "title": "Payment for ${user.fullName}",
          "description": "Paying for service",
        },
        "meta": {"hide_receipt": "true"}
      });

      final request = http.Request(
        'POST',
        Uri.parse('https://api.chapa.co/v1/transaction/initialize'),
      );
      request.headers.addAll(headers);
      request.body = body;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        final paymentUrl = jsonResponse['data']['checkout_url'];

        print('Payment URL: $paymentUrl');

        // Optionally open the payment URL in a webview or browser
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('Failed: $errorResponse');
      }
    } catch (e) {
      print('Payment initialization error: $e');
    }
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
