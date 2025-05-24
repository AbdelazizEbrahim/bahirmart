import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;
import 'package:bahirmart/core/models/category_model.dart' as cat;
import 'package:bahirmart/core/models/product_model.dart' as prod_model;

class ProductService {
  static final String? _baseUrl = dotenv.env['BASE_URL'];

  Future<Position?> _getUserLocation() async {
    try {
      print('Checking if location services are enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        throw Exception('Location services are disabled.');
      }
      print('Location services are enabled.');

      print('Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        print('Permission is denied. Requesting permission...');
        permission = await Geolocator.requestPermission();
        print('Requested permission, new status: $permission');

        if (permission == LocationPermission.denied) {
          print('Permission denied again after request.');
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permission is permanently denied.');
        throw Exception('Location permissions are permanently denied.');
      }

      print('Fetching current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Location fetched successfully: $position');
      return position;
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  Future<List<ad_model.Ad>> fetchAds({
    String? center, // Format: "lat-lng" (e.g., "40.7128-74.0060")
    int? radius, // In meters, default is 50000
    int page = 1,
    int limit = 100,
  }) async {
    try {
      // If center is not provided, try to fetch the user's location
      String? finalCenter = center;
      if (finalCenter == null) {
        Position? position = await _getUserLocation();
        if (position != null) {
          finalCenter = '${position.latitude}-${position.longitude}';
        }
      }

      // Build the query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'isHome': 'false',
        if (finalCenter != null) 'center': finalCenter,
        if (radius != null) 'radius': radius.toString(),
      };

      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/advertisement')
          .replace(queryParameters: queryParams);

      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Ads response status: ${response.statusCode}');
      print('Ads response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the 'ads' field exists and is a list, return empty list if null or empty
        if (data['ads'] is List && data['ads'].isNotEmpty) {
          return List<ad_model.Ad>.from(
            data['ads'].map((item) => ad_model.Ad.fromJson(item)),
          );
        }
        return [];
      } else {
        throw Exception('Failed to fetch ads: ${response.body}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }

  Future<List<prod_model.Product>> fetchProducts({
    String? center, // Format: "lat-lng" (e.g., "40.7128-74.0060")
    int? radius, // In meters
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final position = await _getUserLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;
      print('Base URL: $_baseUrl');
      // If center is not provided, try to fetch the user's location
      String? finalCenter = center;
      if (finalCenter == null) {
        Position? position = await _getUserLocation();
        if (position != null) {
          finalCenter = '${position.latitude}-${position.longitude}';
          print('Resolved center from location: $finalCenter');
        } else {
          print(
              '[WARNING] Could not resolve user location. No center will be sent.');
        }
      }

      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (radius != null) 'radius': radius.toString(),
      };

      print('Query parameters for products: $queryParams');

      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/fetchProducts')
          .replace(queryParameters: queryParams);

      print('Full URI for product fetch: $uri');

      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Products response status: ${response.statusCode}');
      print('Products response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the 'products' field exists and is a list, return empty list if null or empty
        if (data['products'] is List && data['products'].isNotEmpty) {
          final products = List<prod_model.Product>.from(
            data['products'].map((item) => prod_model.Product.fromJson(item)),
          );
          print(
              'Fetched ${products.length} products: ${products.map((p) => p.productName).toList()}');
          return products;
        }
        print('No products found in response');
        return [];
      } else {
        throw Exception('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<cat.Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Categories response status: ${response.statusCode}');
      print('Categories response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if data is a list and not empty, return empty list if null or empty
        if (data is List && data.isNotEmpty) {
          return List<cat.Category>.from(
            data.map((item) => cat.Category.fromJson(item)),
          );
        }
        return [];
      } else {
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
