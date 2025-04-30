import 'package:flutter/material.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/models/auction_model.dart';
import 'package:bahirmart/pages/auction_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({Key? key}) : super(key: key);

  @override
  _AuctionListPageState createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _selectedStatus = 'All';
  double _minPrice = 0;
  double _maxPrice = 1000000;
  List<Auction> _auctions = [];
  List<Auction> _filteredAuctions = [];

  @override
  void initState() {
    super.initState();
    _loadMockAuctions();
  }

  void _loadMockAuctions() {
    // Mock data
    _auctions = [
      Auction(
        id: '1',
        auctionTitle: 'iPhone 13 Pro Max',
        merchantName: 'Tech Store',
        category: 'Electronics',
        description: 'Brand new iPhone 13 Pro Max 256GB',
        condition: 'new',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 3)),
        itemImg: ['https://picsum.photos/200'],
        startingPrice: 999.99,
        reservedPrice: 1200.00,
        bidIncrement: 10.00,
        status: 'active',
        adminApproval: 'approved',
        paymentDuration: 24,
        totalQuantity: 1,
        remainingQuantity: 1,
        buyByParts: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Auction(
        id: '2',
        auctionTitle: 'Samsung 4K Smart TV',
        merchantName: 'Electronics Hub',
        category: 'Electronics',
        description: '55-inch Samsung 4K Smart TV with HDR',
        condition: 'new',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 5)),
        itemImg: ['https://picsum.photos/201'],
        startingPrice: 699.99,
        reservedPrice: 800.00,
        bidIncrement: 5.00,
        status: 'active',
        adminApproval: 'approved',
        paymentDuration: 48,
        totalQuantity: 1,
        remainingQuantity: 1,
        buyByParts: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Auction(
        id: '3',
        auctionTitle: 'Nike Air Max Sneakers',
        merchantName: 'Sports Gear',
        category: 'Fashion',
        description: 'Limited edition Nike Air Max sneakers',
        condition: 'new',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 2)),
        itemImg: ['https://picsum.photos/202'],
        startingPrice: 149.99,
        reservedPrice: 180.00,
        bidIncrement: 2.00,
        status: 'active',
        adminApproval: 'approved',
        paymentDuration: 24,
        totalQuantity: 1,
        remainingQuantity: 1,
        buyByParts: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Auction(
        id: '4',
        auctionTitle: 'Vintage Leather Jacket',
        merchantName: 'Fashion Forward',
        category: 'Fashion',
        description: 'Genuine leather jacket in excellent condition',
        condition: 'used',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 4)),
        itemImg: ['https://picsum.photos/203'],
        startingPrice: 199.99,
        reservedPrice: 250.00,
        bidIncrement: 5.00,
        status: 'active',
        adminApproval: 'approved',
        paymentDuration: 24,
        totalQuantity: 1,
        remainingQuantity: 1,
        buyByParts: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Auction(
        id: '5',
        auctionTitle: 'Gaming PC Bundle',
        merchantName: 'Gaming Zone',
        category: 'Electronics',
        description: 'High-end gaming PC with RTX 3080, 32GB RAM, 1TB SSD',
        condition: 'new',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 7)),
        itemImg: ['https://picsum.photos/204'],
        startingPrice: 1499.99,
        reservedPrice: 1800.00,
        bidIncrement: 20.00,
        status: 'active',
        adminApproval: 'approved',
        paymentDuration: 72,
        totalQuantity: 1,
        remainingQuantity: 1,
        buyByParts: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    _filterAuctions();
  }

  void _filterAuctions() {
    setState(() {
      _filteredAuctions = _auctions.where((auction) {
        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          if (!auction.auctionTitle.toLowerCase().contains(searchLower) &&
              !auction.description.toLowerCase().contains(searchLower) &&
              !auction.merchantName.toLowerCase().contains(searchLower)) {
            return false;
          }
        }

        // Category filter
        if (_selectedCategory != 'All' && auction.category != _selectedCategory) {
          return false;
        }

        // Condition filter
        if (_selectedCondition != 'All' && auction.condition != _selectedCondition) {
          return false;
        }

        // Status filter
        if (_selectedStatus != 'All' && auction.status != _selectedStatus) {
          return false;
        }

        // Price range filter
        if (auction.startingPrice < _minPrice || auction.startingPrice > _maxPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(title: 'Auctions'),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search auctions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => _filterAuctions(),
                ),
                const SizedBox(height: 16),

                // Filter Toggle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list),
                        const SizedBox(width: 8),
                        Text(_isFilterExpanded ? 'Hide Filters' : 'Show Filters'),
                        const SizedBox(width: 8),
                        Icon(_isFilterExpanded ? Icons.expand_less : Icons.expand_more),
                      ],
                    ),
                  ),
                ),

                // Filter Options
                if (_isFilterExpanded) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        'Category',
                        ['All', 'Electronics', 'Fashion', 'Home', 'Sports'],
                        _selectedCategory,
                        (value) {
                          setState(() {
                            _selectedCategory = value;
                            _filterAuctions();
                          });
                        },
                      ),
                      _buildFilterChip(
                        'Condition',
                        ['All', 'new', 'used'],
                        _selectedCondition,
                        (value) {
                          setState(() {
                            _selectedCondition = value;
                            _filterAuctions();
                          });
                        },
                      ),
                      _buildFilterChip(
                        'Status',
                        ['All', 'active', 'ended', 'pending', 'cancelled'],
                        _selectedStatus,
                        (value) {
                          setState(() {
                            _selectedStatus = value;
                            _filterAuctions();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price Range Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range: \$${_minPrice.toStringAsFixed(2)} - \$${_maxPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 1000000,
                        divisions: 100,
                        labels: RangeLabels(
                          '\$${_minPrice.toStringAsFixed(2)}',
                          '\$${_maxPrice.toStringAsFixed(2)}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                            _filterAuctions();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Auction List
          Expanded(
            child: _filteredAuctions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No auctions found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAuctions.length,
                    itemBuilder: (context, index) {
                      final auction = _filteredAuctions[index];
                      return _buildAuctionCard(auction);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(
    String label,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onSelected(value);
          }
        },
      ),
    );
  }

  Widget _buildAuctionCard(Auction auction) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuctionDetailPage(auction: auction),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auction Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: auction.itemImg.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
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
                          auction.auctionTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(auction.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auction.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(auction.status),
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
                        'Sold by ${auction.merchantName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: auction.condition == 'new' 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auction.condition.toUpperCase(),
                          style: TextStyle(
                            color: auction.condition == 'new' 
                                ? Colors.blue
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Current Bid and Time Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Bid',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            currencyFormat.format(auction.startingPrice),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            auction.formattedTimeRemaining,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Bid Button
                  if (auction.status == 'active')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showBidDialog(auction),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Place Bid'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBidDialog(Auction auction) {
    final TextEditingController bidController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    // Calculate minimum bid
    final minBid = auction.startingPrice + auction.bidIncrement;
    bidController.text = minBid.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place a Bid'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Bid: ${currencyFormat.format(auction.startingPrice)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum Bid: ${currencyFormat.format(minBid)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bidController,
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
                  if (bidAmount <= auction.startingPrice) {
                    return 'Bid must be higher than current bid';
                  }
                  if (bidAmount < minBid) {
                    return 'Minimum bid increment is ${currencyFormat.format(auction.bidIncrement)}';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final bidAmount = double.parse(bidController.text);
                _placeBid(auction, bidAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  void _placeBid(Auction auction, double bidAmount) {
    // Mock API call for placing a bid
    _mockApiCall(
      'placeBid',
      {
        'auctionId': auction.id,
        'bidAmount': bidAmount,
      },
      (response) {
        // Update the auction with the new bid
        setState(() {
          final index = _auctions.indexWhere((a) => a.id == auction.id);
          if (index != -1) {
            // Create a new auction with updated starting price
            final updatedAuction = Auction(
              id: auction.id,
              auctionTitle: auction.auctionTitle,
              merchantName: auction.merchantName,
              category: auction.category,
              description: auction.description,
              condition: auction.condition,
              startTime: auction.startTime,
              endTime: auction.endTime,
              itemImg: auction.itemImg,
              startingPrice: bidAmount, // Update the current bid
              reservedPrice: auction.reservedPrice,
              bidIncrement: auction.bidIncrement,
              rejectionReason: auction.rejectionReason,
              status: auction.status,
              adminApproval: auction.adminApproval,
              paymentDuration: auction.paymentDuration,
              totalQuantity: auction.totalQuantity,
              remainingQuantity: auction.remainingQuantity,
              buyByParts: auction.buyByParts,
              createdAt: auction.createdAt,
              updatedAt: DateTime.now(),
            );
            _auctions[index] = updatedAuction;
            _filterAuctions();
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid placed successfully: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(bidAmount)}'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Mock API call function for future integration
  void _mockApiCall(String endpoint, Map<String, dynamic> data, Function(Map<String, dynamic>) onSuccess) {
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

  Color _getStatusColor(String status) {
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
} 