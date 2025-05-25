import 'package:bahirmart/core/models/order_model.dart';
import 'package:bahirmart/core/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/pages/order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late List<Order> _allOrders;
  List<Order> _filteredOrders = [];
  bool _isFilterPanelOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  // Filter parameters
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _merchantQuery = '';

  @override
  void initState() {
    super.initState();
    _allOrders = [];
    _filteredOrders = [];
    _fetchOrders();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await OrderService.getAllOrders();
      setState(() {
        _allOrders = orders;
        _filteredOrders = List.from(_allOrders);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
        final matchesPaymentStatus = _selectedPaymentStatus == null || order.paymentStatus == _selectedPaymentStatus;
        var matchesDate = true;
        if (_startDate != null && _endDate != null && _startDate!.isAfter(_endDate!)) {
          final temp = _startDate;
          _startDate = _endDate;
          _endDate = temp;
        }
        if (_startDate != null) {
          matchesDate = matchesDate && order.orderDate.isAfter(_startDate!);
        }
        if (_endDate != null) {
          matchesDate = matchesDate && order.orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }
        final matchesMerchant = _merchantQuery.isEmpty || order.merchantDetail.merchantName.toLowerCase().contains(_merchantQuery.toLowerCase());
        return matchesStatus && matchesPaymentStatus && matchesDate && matchesMerchant;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPaymentStatus = null;
      _startDate = null;
      _endDate = null;
      _merchantQuery = '';
      _filteredOrders = List.from(_allOrders);
    });
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelOpen = !_isFilterPanelOpen;
      if (_isFilterPanelOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(
        title: 'My Orders',
        actions: [
          IconButton(
            icon: Icon(
              _isFilterPanelOpen ? Icons.filter_alt_off : Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: _toggleFilterPanel,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (_isFilterPanelOpen)
              SizeTransition(
                sizeFactor: _animation,
                child: _buildFilterPanel(context),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredOrders.isEmpty
                      ? _buildEmptyOrdersView(context)
                      : _buildOrdersList(context, _filteredOrders),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Orders',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Dispatched', child: Text('Dispatched')),
              DropdownMenuItem(value: 'Received', child: Text('Received')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _applyFilters();
              });
            },
            isExpanded: true,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Payment Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            value: _selectedPaymentStatus,
            items: const [
              DropdownMenuItem(value: 'Paid', child: Text('Paid')),
              DropdownMenuItem(value: 'Paid To Merchant', child: Text('Paid To Merchant')),
              DropdownMenuItem(value: 'Pending Refund', child: Text('Pending Refund')),
              DropdownMenuItem(value: 'Refunded', child: Text('Refunded')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentStatus = value;
                _applyFilters();
              });
            },
            isExpanded: true,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          TextField(
            decoration: InputDecoration(
              labelText: 'Merchant Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _merchantQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        _applyFilters();
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    child: Text(
                      _startDate != null ? DateFormat('MMM dd, yyyy').format(_startDate!) : 'Select Start Date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                        _applyFilters();
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    child: Text(
                      _endDate != null ? DateFormat('MMM dd, yyyy').format(_endDate!) : 'Select End Date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            child: const Text('Start Shopping', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(order: order);
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Order #${order.transactionRef.length >= 8 ? order.transactionRef.substring(0, 8) : order.transactionRef}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  _buildStatusChip(context, order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Ordered on ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.store, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Merchant: ${order.merchantDetail.merchantName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${order.products.length} item${order.products.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  _buildPaymentStatusChip(context, order.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    switch (status) {
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'Dispatched':
        chipColor = Colors.blue;
        break;
      case 'Received':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildPaymentStatusChip(BuildContext context, String paymentStatus) {
    Color chipColor;
    switch (paymentStatus) {
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'Paid':
      case 'Paid To Merchant':
        chipColor = Colors.green;
        break;
      case 'Pending Refund':
        chipColor = Colors.red;
        break;
      case 'Refunded':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(paymentStatus, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}