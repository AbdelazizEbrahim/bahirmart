import 'package:bahirmart/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> initializePayment(BuildContext context, double amount, String merchantId) async {
  print('Starting payment initialization');
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    print('Retrieving auth token from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('Token not found');
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to proceed with payment')),
      );
      return;
    }
    print('Token retrieved successfully');

    print('Fetching user data from UserProvider');
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) {
      print('User not loaded in provider');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not available')),
      );
      return;
    }
    print('User data retrieved: ${user.fullName}, ${user.email}');

    print('Preparing request headers and body');
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
      "phone_number": "0912345678", // Replace with actual user phone if available
      "tx_ref": "chewatatest-${DateTime.now().millisecondsSinceEpoch}",
      "callback_url": "https://your-callback-url.com", // Replace with actual server endpoint
      "return_url": "https://your-return-url.com/",
      "customization": {
        "title": "Payment for ${user.fullName}",
        "description": "Paying for service",
      },
      "meta": {"hide_receipt": "true"}
    });

    print('Sending POST request to Chapa API');
    final request = http.Request(
      'POST',
      Uri.parse('https://api.chapa.co/v1/transaction/initialize'),
    );
    request.headers.addAll(headers);
    request.body = body;

    final response = await request.send();
    print('Response received with status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Parsing successful response');
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      final paymentUrl = jsonResponse['data']['checkout_url'];
      print('Checkout URL obtained: $paymentUrl');

      Navigator.pop(context); // Close loading dialog
      print('Navigating to PaymentWebView');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(url: paymentUrl),
        ),
      );
    } else {
      print('Request failed, parsing error response');
      final errorResponse = await response.stream.bytesToString();
      print('Failed with error: $errorResponse');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initialization failed: $errorResponse')),
      );
    }
  } catch (e) {
    print('Payment initialization error occurred: $e');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({Key? key, required this.url}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    print('Initializing WebView with URL: ${widget.url}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            print('WebView page started: $url');
          },
          onPageFinished: (String url) {
            print('WebView page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request to: ${request.url}');
            if (request.url.startsWith('https://your-return-url.com/')) {
              print('Return URL detected, closing WebView');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment process completed')),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              print('User closed WebView manually');
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}