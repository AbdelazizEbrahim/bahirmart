import 'dart:convert';
import 'package:bahirmart/core/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static Future<List<Order>> getAllOrders() async {
    final String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
    final Uri url = Uri.parse('$baseUrl/orderFiltering');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No auth token found. Please log in.');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> ordersJson;

        // Check the type of the decoded data
        if (decoded is List) {
          // Direct list of orders
          ordersJson = decoded;
        } else if (decoded is Map && decoded.containsKey('orders')) {
          // Map with an "orders" key containing the list
          ordersJson = decoded['orders'];
        } else {
          // Unexpected format - log it and throw an error
          print('Unexpected response format: $decoded');
          throw Exception('Unexpected response format: $decoded');
        }

        // Convert the list of JSON objects to Order objects
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load orders. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  static Future<bool> markOrderAsReceived(String orderId) async {
    final String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
    final Uri url = Uri.parse('$baseUrl/order');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No auth token found.');
        throw Exception('No auth token found. Please log in.');
      }

      final Map<String, dynamic> requestBody = {
        '_id': orderId,
        'status': 'Received',
      };

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order marked as received successfully.');
        return true;
      }

      throw Exception(
          'Failed to mark order as received: ${response.statusCode}');
    } catch (e) {
      print('Error marking order as received: $e');
      throw Exception('Error marking order as received: $e');
    }
  }

  static Future<bool> requestRefund(String orderId, String reason,
      {String? description}) async {
    final String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
    final Uri url = Uri.parse('$baseUrl/askrefund'); // Assuming this route
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No auth token found. Please log in.');

      final body = {
        '_id': orderId,
        'reason': reason,
        if (description != null) 'description': description,
      };

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) return true;
      throw Exception(
          'Failed to request refund: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Error requesting refund: $e');
    }
  }

  static Future<bool> updateCustomerInfo(
      String orderId, CustomerDetail customerDetail) async {
    final String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
    final Uri url = Uri.parse('$baseUrl/order');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No auth token found. Please log in.');

      final Map<String, dynamic> requestBody = {
        '_id': orderId,
        'customerDetail': customerDetail.toJson(),
      };

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) return true;

      debugPrint('Update failed: ${response.body}');
      throw Exception('Failed to update customer info: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating customer info: $e');
    }
  }
}
