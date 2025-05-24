import 'package:flutter/material.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/models/auction_model.dart';
import 'package:bahirmart/pages/auction_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:bahirmart/core/services/auction_service.dart';

final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({Key? key}) : super(key: key);

  @override
  _AuctionListPageState createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFilterExpanded = false;
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _selectedStatus = 'All';
  double _minPrice = 0;
  double _maxPrice = 1000000;
  List<Auction> _auctions = [];
  List<Auction> _filteredAuctions = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _limit = 12;
  final AuctionService _auctionService = AuctionService();
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
    _fetchAuctions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchAuctions();
      }
    });
  }

  Future<void> _fetchAuctions() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final newAuctions = await _auctionService.fetchAuctions(_currentPage, _limit);
      setState(() {
        _auctions.addAll(newAuctions);
        _filteredAuctions = _auctions;
        _currentPage++;
        _hasMore = newAuctions.length == _limit;
        _filterAuctions();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching auctions: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterAuctions() {
    setState(() {
      _filteredAuctions = _auctions.where((auction) {
        final searchLower = _searchController.text.toLowerCase();
        if (searchLower.isNotEmpty) {
          if (!(auction.auctionTitle?.toLowerCase().contains(searchLower) ?? false) &&
              !(auction.description?.toLowerCase().contains(searchLower) ?? false) &&
              !(auction.merchantName?.toLowerCase().contains(searchLower) ?? false)) {
            return false;
          }
        }

        if (_selectedCategory != 'All' && auction.category != _selectedCategory) {
          return false;
        }

        if (_selectedCondition != 'All' && auction.condition != _selectedCondition) {
          return false;
        }

        if (_selectedStatus != 'All' && auction.status != _selectedStatus) {
          return false;
        }

        final price = auction.startingPrice ?? 0.0;
        if (price < _minPrice || price > _maxPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  List<String> get _uniqueCategories {
    final categories = _auctions
        .map((auction) => auction.category ?? 'Unknown')
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  void _applyPriceFilter() {
    final minText = _minPriceController.text;
    final maxText = _maxPriceController.text;

    final min = double.tryParse(minText) ?? 0.0;
    final max = double.tryParse(maxText) ?? double.maxFinite;

    if (min > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Min price cannot be greater than max price')),
      );
      return;
    }

    setState(() {
      _minPrice = min;
      _maxPrice = max;
      _filterAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(title: 'Auctions'),
      body: Column(
        children: [
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
                if (_isFilterExpanded) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        'Category',
                        _uniqueCategories,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _applyPriceFilter,
                    child: const Text('Apply Price Filter'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _auctions.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAuctions.isEmpty
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAuctions.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredAuctions.length && _hasMore) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final auction = _filteredAuctions[index];
                          return _buildAuctionCard(auction);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BahirMartBottomNavigationBar(currentIndex: 2),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: auction.itemImg?.isNotEmpty == true
                    ? auction.itemImg!.first
                    : 'https://via.placeholder.com/150',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          auction.auctionTitle ?? 'Untitled Auction',
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
                          color: _getStatusColor(auction.status ?? 'pending')
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (auction.status ?? 'pending').toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(auction.status ?? 'pending'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sold by ${auction.merchantName ?? 'Unknown'}',
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
                          color: (auction.condition ?? 'new') == 'new'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (auction.condition ?? 'new').toUpperCase(),
                          style: TextStyle(
                            color: (auction.condition ?? 'new') == 'new'
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
                            currencyFormat.format(auction.startingPrice ?? 0.0),
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

    final minBid = (auction.startingPrice ?? 0.0) + (auction.bidIncrement ?? 1.0);
    bidController.text = minBid.toStringAsFixed(2);

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
                'Current Bid: ${currencyFormat.format(auction.startingPrice ?? 0.0)}',
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
                  if (bidAmount <= (auction.startingPrice ?? 0.0)) {
                    return 'Bid must be higher than current bid';
                  }
                  if (bidAmount < minBid) {
                    return 'Minimum bid increment is ${currencyFormat.format(auction.bidIncrement ?? 1.0)}';
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

  void _placeBid(Auction auction, double bidAmount) async {
    try {
      final updatedAuction = await _auctionService.placeBid(auction.id!, bidAmount);
      setState(() {
        final index = _auctions.indexWhere((a) => a.id == auction.id);
        if (index != -1) {
          _auctions[index] = updatedAuction;
          _filterAuctions();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Bid placed successfully: ${currencyFormat.format(bidAmount)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing bid: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    _searchController.dispose();
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}