import 'dart:convert';
import 'package:bahirmart/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bahirmart/core/models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_products';
  List<CartProduct> _products = [];

  static final String _baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  List<CartProduct> get products => _products;

  int get productCount => _products.length;

  double get subtotal {
    return _products.fold(
        0,
        (sum, product) =>
            sum + (product.product.currentPrice * product.quantity));
  }

  double get deliveryCost {
    return calculateDeliveryCost();
  }

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
      _products =
          cartData.map((product) => CartProduct.fromJson(product)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson =
        json.encode(_products.map((product) => product.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    final existingIndex =
        _products.indexWhere((p) => p.product.id == product.id);

    if (existingIndex >= 0) {
      _products[existingIndex] = CartProduct(
        product: product,
        quantity: _products[existingIndex].quantity + quantity,
      );
    } else {
      _products.add(CartProduct(product: product, quantity: quantity));
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeProduct(String productId) async {
    _products.removeWhere((p) => p.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeProduct(productId);
      return;
    }

    final index = _products.indexWhere((p) => p.product.id == productId);
    if (index >= 0) {
      _products[index] = CartProduct(
        product: _products[index].product,
        quantity: quantity,
      );
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _products = [];
    await _saveCart();
    notifyListeners();
  }

  Map<String, List<CartProduct>> getProductsByMerchant() {
    final Map<String, List<CartProduct>> merchantGroups = {};

    for (final product in _products) {
      final merchantId = product.product.merchantDetail.merchantId;
      if (!merchantGroups.containsKey(merchantId)) {
        merchantGroups[merchantId] = [];
      }
      merchantGroups[merchantId]!.add(product);
    }

    return merchantGroups;
  }

  double getMerchantSubtotal(String merchantId) {
    final merchantProducts = _products
        .where((product) =>
            product.product.merchantDetail.merchantId == merchantId)
        .toList();
    return merchantProducts.fold(
        0,
        (sum, product) =>
            sum + (product.product.currentPrice * product.quantity));
  }

  double getMerchantDeliveryCost(String merchantId) {
    final merchantProducts = _products
        .where((product) =>
            product.product.merchantDetail.merchantId == merchantId)
        .toList();
    return merchantProducts.fold(
        0,
        (sum, product) =>
            sum + product.product.calculateDeliveryCost(product.quantity));
  }

  double getMerchantTotal(String merchantId) {
    return getMerchantSubtotal(merchantId) +
        getMerchantDeliveryCost(merchantId);
  }

  double calculateDeliveryCost() {
    double totalDeliveryCost = 0;
    for (var product in _products) {
      totalDeliveryCost +=
          product.product.calculateDeliveryCost(product.quantity);
    }
    return totalDeliveryCost;
  }

  Future<Position?> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  void removeProducts(List<String> productIds) {
    products.removeWhere((item) => productIds.contains(item.product.id));
    notifyListeners();
  }

  Future<bool> verifyPayment(String txRef) async {
    print("Calling verify");
    dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

    final url = Uri.parse('$_baseUrl/verifyPayment?tx_ref=$txRef');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> initializePayment(
    BuildContext context,
    String merchantId,
    List<CartProduct> merchantProducts,
    double total,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please log in to proceed with checkout')),
        );
        return null;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User information not available')),
        );
        return null;
      }

      final position = await _getUserLocation();
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch your location')),
        );
        return null;
      }

      final orderData = {
        'user': {
          'id': user.id,
          'email': user.email,
          'fullName': user.fullName,
        },
        'merchantId': merchantId,
        'products': merchantProducts
            .map((product) => {
                  'productId': product.product.id,
                  'productName': product.product.productName,
                  'quantity': product.quantity,
                  'price': product.product.currentPrice,
                  'deliveryType': product.product.delivery,
                  'deliveryPrice': product.product.deliveryPrice,
                })
            .toList(),
        'subtotal': merchantProducts.fold<double>(
          0,
          (sum, p) => sum + (p.product.currentPrice * p.quantity),
        ),
        'deliveryCost': Provider.of<CartService>(context, listen: false)
            .getMerchantDeliveryCost(merchantId),
        'total': total,
        'currency': 'ETB',
        'timestamp': DateTime.now().toIso8601String(),
        'location': {
          'coordinates': [position.longitude, position.latitude],
        },
      };

      final url = Uri.parse('$_baseUrl/checkout/mobile');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'checkout_url': responseData['checkout_url'],
          'tx_ref': responseData['tx_ref'],
          'orderId': responseData['orderId'],
        };
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Checkout failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $error')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error initializing payment')),
      );
      return null;
    }
  }
}

class CartProduct {
  final Product product;
  final int quantity;

  CartProduct({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}
