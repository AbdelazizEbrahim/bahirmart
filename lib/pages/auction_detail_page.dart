import 'package:flutter/material.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/core/models/auction_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AuctionDetailPage extends StatefulWidget {
  final Auction auction;

  const AuctionDetailPage({
    Key? key,
    required this.auction,
  }) : super(key: key);

  @override
  _AuctionDetailPageState createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  final TextEditingController _bidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentImageIndex = 0;
  double _currentBid = 0;

  @override
  void initState() {
    super.initState();
    _currentBid = widget.auction.startingPrice ?? 0.0;
    _bidController.text = _currentBid.toStringAsFixed(2);
  }

  void _placeBid() {
    if (_formKey.currentState!.validate()) {
      final bidAmount = double.parse(_bidController.text);
      if (bidAmount <= _currentBid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid amount must be higher than current bid'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Mock API call for placing a bid
      _mockApiCall(
        'placeBid',
        {
          'auctionId': widget.auction.id ?? '',
          'bidAmount': bidAmount,
        },
        (response) {
          // Update the current bid
          setState(() {
            _currentBid = bidAmount;
            _bidController.text = _currentBid.toStringAsFixed(2);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Bid placed successfully: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(bidAmount)}'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  // Mock API call function for future integration
  void _mockApiCall(String endpoint, Map<String, dynamic> data,
      Function(Map<String, dynamic>) onSuccess) {
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Mock successful response
      final response = {
        'success': true,
        'message': 'Operation completed successfully',
        'data': data,
      };
      onSuccess(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: const BahirMartAppBar(title: 'Auction Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: (widget.auction.itemImg?.isNotEmpty == true
                          ? widget.auction.itemImg!
                          : ['https://via.placeholder.com/150'])
                      .map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      },
                    );
                  }).toList(),
                ),
                // Image Indicators
                if (widget.auction.itemImg?.isNotEmpty == true &&
                    widget.auction.itemImg!.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.auction.itemImg!.asMap().entries.map((entry) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(
                                    _currentImageIndex == entry.key ? 0.9 : 0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.auction.auctionTitle ?? 'Untitled Auction',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.auction.status ?? 'pending')
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (widget.auction.status ?? 'pending').toUpperCase(),
                          style: TextStyle(
                            color:
                                _getStatusColor(widget.auction.status ?? 'pending'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Merchant Name and Condition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sold by ${widget.auction.merchantName ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (widget.auction.condition ?? 'new') == 'new'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (widget.auction.condition ?? 'new').toUpperCase(),
                          style: TextStyle(
                            color:
                                (widget.auction.condition ?? 'new') == 'new'
                                    ? Colors.blue
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.auction.description ?? 'No description available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Item Details
                  _buildDetailRow(
                      'Category', widget.auction.category ?? 'Unknown'),
                  _buildDetailRow(
                      'Condition', widget.auction.condition ?? 'Unknown'),
                  _buildDetailRow(
                      'Quantity',
                      '${widget.auction.remainingQuantity ?? 1} of ${widget.auction.totalQuantity ?? 1}'),
                  _buildDetailRow(
                      'Payment Duration',
                      '${widget.auction.paymentDuration ?? 24} hours'),
                  const SizedBox(height: 16),

                  // Time Remaining
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 8),
                        Text(
                          widget.auction.formattedTimeRemaining,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bidding Section
                  if (widget.auction.status == 'active') ...[
                    Text(
                      'Current Bid',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(_currentBid),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _bidController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Your Bid Amount',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a bid amount';
                              }
                              final bidAmount = double.tryParse(value);
                              if (bidAmount == null) {
                                return 'Please enter a valid number';
                              }
                              if (bidAmount <= _currentBid) {
                                return 'Bid must be higher than current bid';
                              }
                              final minBid = _currentBid +
                                  (widget.auction.bidIncrement ?? 1.0);
                              if (bidAmount < minBid) {
                                return 'Minimum bid increment is ${currencyFormat.format(widget.auction.bidIncrement ?? 1.0)}';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _placeBid,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Place Bid'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'ended':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }
}