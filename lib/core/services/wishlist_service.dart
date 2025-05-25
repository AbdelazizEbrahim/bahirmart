import 'package:bahirmart/core/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WishlistService {
  static String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  static Future<List<Product>> fetchWishlist(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/wishlist/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  static Future<void> addToWishlist(String userId, String productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wishlist/$userId'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to wishlist');
    }
  }

  static Future<void> removeFromWishlist(
      String userId, String productId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/wishlist/$userId/$productId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from wishlist');
    }
  }
}
