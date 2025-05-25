import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:bahirmart/core/models/category_model.dart' as cat;
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;

class LandingService {
  // Base URL for the API (replace with your actual API base URL)
  static final String? _baseUrl = dotenv.env['BASE_URL'];

  Future<Position?> _getUserLocation() async {
    try {
      print('Checking if location services are enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        throw Exception('Location services are disabled.');
      }

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

  Future<List<prod_model.Product>> fetchBestSellers() async {
    print('➡️ Fetching best sellers...');
    try {
      final position = await _getUserLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;

      final uri = Uri.parse('$_baseUrl/homePageFilter').replace(
        queryParameters: {
          'type': 'bestSellers',
          'page': '1',
          'limit': '12',
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );

      print('🌐 Sending GET request to: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] is List) {
          print('✅ Best sellers fetched successfully.');
          return List<prod_model.Product>.from(
            data['products'].map((item) => prod_model.Product.fromJson(item)),
          );
        } else {
          throw Exception('Invalid response format: No product data found');
        }
      } else {
        throw Exception('Failed to fetch best sellers: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error: $e');
      throw Exception('Error fetching best sellers: $e');
    }
  }

  Future<List<prod_model.Product>> fetchTopRated() async {
    print('➡️ Fetching top-rated products...');
    try {
      final position = await _getUserLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;

      final uri = Uri.parse('$_baseUrl/homePageFilter').replace(
        queryParameters: {
          'type': 'topRated',
          'page': '1',
          'limit': '12',
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );

      print('🌐 Sending GET request to: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] is List) {
          print('✅ Top-rated products fetched successfully.');
          return List<prod_model.Product>.from(
            data['products'].map((item) => prod_model.Product.fromJson(item)),
          );
        } else {
          throw Exception('Invalid response format: No product data found');
        }
      } else {
        throw Exception('Failed to fetch top-rated products: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error: $e');
      throw Exception('Error fetching top-rated products: $e');
    }
  }

  Future<List<prod_model.Product>> fetchNewArrivals() async {
    print('➡️ Fetching new arrivals...');
    try {
      final position = await _getUserLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;

      final uri = Uri.parse('$_baseUrl/homePageFilter').replace(
        queryParameters: {
          'type': 'latestProducts',
          'page': '1',
          'limit': '12',
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );

      print('🌐 Sending GET request to: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] is List) {
          print('✅ New arrivals fetched successfully.');
          return List<prod_model.Product>.from(
            data['products'].map((item) => prod_model.Product.fromJson(item)),
          );
        } else {
          throw Exception('Invalid response format: No product data found');
        }
      } else {
        throw Exception('Failed to fetch new arrivals: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error: $e');
      throw Exception('Error fetching new arrivals: $e');
    }
  }

  Future<ProductResponse> fetchProductsByCategory({
    String? categoryId,
    double? lat,
    double? lng,
    int limit = 1000,
  }) async {
    try {
      // final position = await _getUserLocation();
      // final lat = position?.latitude;
      // final lng = position?.longitude;
      print('Starting fetchProductsByCategory...');
      print(
          'Parameters: categoryId=$categoryId, lat=$lat, lng=$lng, limit=$limit');

      // Build query parameters
      final queryParams = {
        'limit': limit.toString(),
        if (categoryId != null) 'category': categoryId,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
      };
      print('Query parameters built: $queryParams');

      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/fetchProducts')
          .replace(queryParameters: queryParams);
      print('Constructed URI: $uri');

      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('HTTP GET request sent. Status code: ${response.statusCode}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response body decoded: $data');

        // Check if the 'products' field exists and is a list
        if (data['products'] is List) {
          print('Products list found. Mapping to Product model...');
          return ProductResponse(
            products: List<prod_model.Product>.from(
              data['products'].map((item) => prod_model.Product.fromJson(item)),
            ),
            total: data['total'] ?? 0,
            message: data['message'] ?? '',
          );
        } else {
          print('Error: Invalid response format: No products data found');
          throw Exception('Invalid response format: No products data found');
        }
      } else {
        print('Error: Failed to fetch products: ${response.body}');
        throw Exception('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  /// Fetches categories
  Future<List<cat.Category>> fetchCategories() async {
    try {
      // Make the HTTP GET request
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // The API returns a list of categories directly
        if (data is List) {
          return List<cat.Category>.from(
            data.map((item) => cat.Category.fromJson(item)),
          );
        } else {
          throw Exception(
              'Invalid response format: Expected a list of categories');
        }
      } else {
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<ProductResponse> fetchProducts({
    double? lat,
    double? lng,
    int limit = 1000,
  }) async {
    final position = await _getUserLocation();
    final lat = position?.latitude;
    final lng = position?.longitude;

    try {
      print('Starting fetchProducts...');
      print('Parameters lat=$lat, lng=$lng, limit=$limit');

      // Build query parameters
      final queryParams = {
        'limit': limit.toString(),
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
      };
      print('Query parameters built1: $queryParams');

      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/fetchProducts')
          .replace(queryParameters: queryParams);
      print('Constructed URI: $uri');

      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('HTTP GET request sent. Status code prod: ${response.statusCode}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response body decoded: $data');

        // Check if the 'products' field exists and is a list
        if (data['products'] is List) {
          print('Products list found. Mapping to Product model...');
          return ProductResponse(
            products: List<prod_model.Product>.from(
              data['products'].map((item) => prod_model.Product.fromJson(item)),
            ),
            total: data['total'] ?? 0,
            message: data['message'] ?? '',
          );
        } else {
          print('Error: Invalid response format: No products data found');
          throw Exception('Invalid response format: No products data found');
        }
      } else {
        print('Error: Failed to fetch products: ${response.body}');
        throw Exception('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<ad_model.Ad>> fetchAds({
    String? center, // Format: "lat-lng" (e.g., "40.7128-74.0060")
    int? radius, // In meters, default is 50000
    int page = 1,
    int limit = 5,
    bool? isHome,
  }) async {
    try {
      if (center == null) {
        final position = await _getUserLocation();
        if (position != null) {
          center = '${position.latitude}-${position.longitude}';
        } else {
          throw Exception('User location unavailable.');
        }
      }

      // Build the query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'center': center,
        'radius': (radius ?? 50000).toString(), // Default radius
        'isHome':
            isHome?.toString() ?? '', // Always include isHome, even if null
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

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ads'] is List) {
          return List<ad_model.Ad>.from(
            data['ads'].map((item) => ad_model.Ad.fromJson(item)),
          );
        } else {
          throw Exception('Invalid response format: No ads data found');
        }
      } else {
        throw Exception('Failed to fetch ads: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching ads: $e');
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final categories = await fetchCategories();
      final products = await fetchProducts();
      return {
        'categories': categories,
        'products': products.products.take(12).toList(),
      };
    } catch (e) {
      throw Exception('Error fetching initial data: $e');
    }
  }
}

/// Model for the product response including products, total, and message
class ProductResponse {
  final List<prod_model.Product> products;
  final int total;
  final String message;

  ProductResponse({
    required this.products,
    required this.total,
    required this.message,
  });
}
