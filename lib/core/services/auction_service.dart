import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bahirmart/core/models/auction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionService {
  static final String? baseUrl = dotenv.env['BASE_URL'];

  Future<List<Auction>> fetchAuctions(int page, int limit) async {
    final url = '$baseUrl/fetchAuctions/mobile?page=$page&limit=$limit';
    print('🔍 Fetching auctions from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        dynamic decoded;

        // Check if response body is actually a JSON-encoded string (double-encoded)
        try {
          decoded = jsonDecode(response.body);
          if (decoded is String) {
            print('⚠️ Response was a JSON-encoded string. Decoding again...');
            decoded = jsonDecode(decoded);
          }
        } catch (e) {
          print('🚨 Error decoding response body: $e');
          rethrow;
        }

        print('✅ Decoded JSON: $decoded');

        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] ?? []);

        print('📋 Extracted data list: $data');

        final List<Auction> auctions =
            data.map((json) => Auction.fromJson(json)).toList().cast<Auction>();

        print('🎯 Mapped auctions: $auctions');
        return auctions;
      } else {
        print('❌ Failed to fetch auctions: ${response.body}');
        throw Exception('Failed to fetch auctions: ${response.body}');
      }
    } catch (e) {
      print('🚨 Exception while fetching auctions: $e');
      rethrow;
    }
  }

  /// Places a bid on an auction and returns the updated auction data.

  Future<Auction> placeBid(String auctionId, double bidAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/bid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'auctionId': auctionId,
        'bidAmount': bidAmount,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['message'] == null ||
          data['highestBid'] == null ||
          data['totalBids'] == null) {
        throw Exception('Invalid response format');
      }
      // Update the Auction object with the response data
      return Auction.fromJson({
        'id': auctionId,
        'highestBid': data['highestBid'],
        'totalBids': data['totalBids'],
        // Include other necessary fields if required by Auction.fromJson
      });
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Failed to place bid: ${response.body}');
    }
  }
}
