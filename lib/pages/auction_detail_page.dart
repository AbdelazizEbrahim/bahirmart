import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/image_carousel.dart';
import '../models//auctions.dart';

class AuctionDetailPage extends StatefulWidget {
  final Auction auction;

  AuctionDetailPage({required this.auction});

  @override
  _AuctionDetailPageState createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  final TextEditingController _bidController = TextEditingController();
  double? _currentHighestBid;
  String? _errorMessage;

  void _placeBid() {
    final bidValue = double.tryParse(_bidController.text);
    final minBid = (_currentHighestBid ?? widget.auction.startingPrice) + widget.auction.bidIncrement;

    if (bidValue == null) {
      setState(() => _errorMessage = 'Please enter a valid number');
    } else if (bidValue < minBid) {
      setState(() => _errorMessage = 'Bid must be at least \$${minBid.toStringAsFixed(2)}');
    } else {
      setState(() {
        _currentHighestBid = bidValue;
        _errorMessage = null;
        _bidController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid placed successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Carousel
            ImageCarousel(images: widget.auction.itemImg),
            // Auction Details
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.auction.auctionTitle ?? 'Auction ${widget.auction.id}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Merchant: ${widget.auction.merchantName}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.auction.description ?? 'No description available.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Condition: ${widget.auction.condition.capitalize()}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start Time: ${widget.auction.startTime.toLocal().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'End Time: ${widget.auction.endTime.toLocal().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Starting Price: \$${widget.auction.startingPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reserved Price: \$${widget.auction.reservedPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bid Increment: \$${widget.auction.bidIncrement.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Remaining Quantity: ${widget.auction.remainingQuantity}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  if (_currentHighestBid != null)
                    Text(
                      'Current Highest Bid: \$${ _currentHighestBid!.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                ],
              ),
            ),
            // Place Bid Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Place Your Bid',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter your bid',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorText: _errorMessage,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _placeBid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Bid Now', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}