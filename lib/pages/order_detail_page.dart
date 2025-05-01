import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/order_model.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with SingleTickerProviderStateMixin {
  late Order _order;
  bool _isEditingCustomerInfo = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _selectedRefundReason;
  final TextEditingController _customRefundReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _nameController = TextEditingController(text: _order.customerDetail.customerName);
    _phoneController = TextEditingController(text: _order.customerDetail.phoneNumber);
    _stateController = TextEditingController(text: _order.customerDetail.address.state);
    _cityController = TextEditingController(text: _order.customerDetail.address.city);

    // Initialize animation controller for UI transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _customRefundReasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCustomerInfoEditing() {
    setState(() {
      _isEditingCustomerInfo = !_isEditingCustomerInfo;
    });
  }

  void _cancelCustomerInfoEdit() {
    setState(() {
      _isEditingCustomerInfo = false;
      _nameController.text = _order.customerDetail.customerName;
      _phoneController.text = _order.customerDetail.phoneNumber;
      _stateController.text = _order.customerDetail.address.state;
      _cityController.text = _order.customerDetail.address.city;
    });
  }

  void _saveCustomerInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _order = Order(
          id: _order.id,
          customerDetail: CustomerDetail(
            customerId: _order.customerDetail.customerId,
            customerName: _nameController.text,
            phoneNumber: _phoneController.text,
            customerEmail: _order.customerDetail.customerEmail,
            address: Address(
              state: _stateController.text,
              city: _cityController.text,
            ),
          ),
          merchantDetail: _order.merchantDetail,
          products: _order.products,
          auction: _order.auction,
          totalPrice: _order.totalPrice,
          status: _order.status,
          paymentStatus: _order.paymentStatus,
          location: _order.location,
          transactionRef: _order.transactionRef,
          orderDate: _order.orderDate,
          refundReason: _order.refundReason,
        );
        _isEditingCustomerInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer information updated successfully')),
      );
    }
  }

  bool _canRequestRefund() {
    return _order.status != 'Received' &&
        _order.paymentStatus != 'Refunded' &&
        _order.paymentStatus != 'Pending Refund';
  }

  void _requestRefund() {
    _selectedRefundReason = null;
    _customRefundReasonController.clear();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Refund',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a reason for your refund request:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                hint: const Text('Choose a reason'),
                value: _selectedRefundReason,
                items: const [
                  DropdownMenuItem(value: 'Item not as described', child: Text('Item not as described')),
                  DropdownMenuItem(value: 'Changed mind', child: Text('Changed mind')),
                  DropdownMenuItem(value: 'Delivery issue', child: Text('Delivery issue')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRefundReason = value;
                  });
                },
              ),
              if (_selectedRefundReason == 'Other') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _customRefundReasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Please specify your reason...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_selectedRefundReason == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a refund reason')),
                        );
                        return;
                      }
                      final reason = _selectedRefundReason == 'Other'
                          ? _customRefundReasonController.text
                          : _selectedRefundReason!;
                      if (_selectedRefundReason == 'Other' && reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please specify a reason')),
                        );
                        return;
                      }
                      // In a real app, submit refund request to backend
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Refund request submitted: $reason')),
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(
        title: 'Order Details',
        actions: [
          if (_order.status != 'Dispatched' && _order.status != 'Received')
            IconButton(
              icon: Icon(
                _isEditingCustomerInfo ? Icons.save : Icons.edit,
                color: Colors.white,
              ),
              onPressed: _toggleCustomerInfoEditing,
              tooltip: 'Edit Customer Info',
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_canRequestRefund()) _buildRefundCard(),
                _buildOrderStatusCard(),
                _buildOrderInfoCard(),
                _buildCustomerInfoCard(),
                _buildMerchantInfoCard(),
                _buildProductsCard(),
                if (_order.auction != null) _buildAuctionCard(),
                _buildPaymentInfoCard(),
                _buildDeliveryTrackingCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefundCard() {
    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need a Refund?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Request a refund for this order',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _requestRefund,
                icon: const Icon(Icons.assignment_return, size: 20),
                label: const Text('Request Refund'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Order Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusTimeline(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                _buildPaymentStatusChip(_order.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    const statuses = ['Pending', 'Dispatched', 'Received'];
    final currentStatusIndex = statuses.indexOf(_order.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentStatusIndex;
        final isCurrent = index == currentStatusIndex;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[200],
                  border: isCurrent
                      ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statuses[index],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isCurrent ? Theme.of(context).primaryColor : Colors.grey[600],
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Order Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order ID', _order.transactionRef),
            _buildInfoRow(
              'Order Date',
              DateFormat('MMM dd, yyyy HH:mm').format(_order.orderDate),
            ),
            _buildInfoRow('Total Amount', '\$${_order.totalPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Delivery Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                    ),
                  ],
                ),
                if (_order.status != 'Dispatched' && _order.status != 'Received')
                  TextButton.icon(
                    onPressed: _toggleCustomerInfoEditing,
                    icon: Icon(
                      _isEditingCustomerInfo ? Icons.save : Icons.edit,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      _isEditingCustomerInfo ? 'Save' : 'Edit',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _isEditingCustomerInfo
                ? _buildCustomerInfoEditForm()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', _order.customerDetail.customerName),
                      _buildInfoRow('Phone', _order.customerDetail.phoneNumber),
                      _buildInfoRow('Email', _order.customerDetail.customerEmail),
                      _buildInfoRow('State', _order.customerDetail.address.state),
                      _buildInfoRow('City', _order.customerDetail.address.city),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _stateController,
            decoration: InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a state';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelCustomerInfoEdit,
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveCustomerInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Merchant Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _order.merchantDetail.merchantName),
            _buildInfoRow('Phone', _order.merchantDetail.phoneNumber),
            _buildInfoRow('Email', _order.merchantDetail.merchantEmail),
            const Divider(height: 24),
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Account Name', _order.merchantDetail.accountName),
            _buildInfoRow('Account Number', _order.merchantDetail.accountNumber),
            if (_order.merchantDetail.merchantReference != null)
              _buildInfoRow('Reference', _order.merchantDetail.merchantReference!),
            _buildInfoRow('Bank Code', _order.merchantDetail.bankCode),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order.products.length,
              itemBuilder: (context, index) {
                final product = _order.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${product.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Price: \$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Delivery: ${_getDeliveryInfo(product)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(product.price * product.quantity + product.deliveryPrice).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionCard() {
    if (_order.auction == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Auction Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Auction ID', _order.auction!.auctionId),
            _buildInfoRow('Delivery Type', _order.auction!. delivery),
            _buildInfoRow(
              'Delivery Price',
              '\$${_order.auction!.deliveryPrice.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Payment Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Transaction Reference', _order.transactionRef),
            _buildInfoRow('Payment Status', _order.paymentStatus),
            if (_order.refundReason != null)
              _buildInfoRow('Refund Reason', _order.refundReason!),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTrackingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Delivery Tracking',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_order.status == 'Pending')
              _buildTrackingInfo(
                'Order Placed',
                'Your order has been placed and is waiting to be processed',
                true,
              )
            else if (_order.status == 'Dispatched')
              Column(
                children: [
                  _buildTrackingInfo(
                    'Order Placed',
                    'Your order has been placed',
                    true,
                  ),
                  _buildTrackingInfo(
                    'Order Dispatched',
                    'Your order is on the way',
                    true,
                  ),
                  _buildTrackingInfo(
                    'Order Delivered',
                    'Your order will be delivered soon',
                    false,
                  ),
                ],
              )
            else if (_order.status == 'Received')
              Column(
                children: [
                  _buildTrackingInfo(
                    'Order Placed',
                    'Your order has been placed',
                    true,
                  ),
                  _buildTrackingInfo(
                    'Order Dispatched',
                    'Your order is on the way',
                    true,
                  ),
                  _buildTrackingInfo(
                    'Order Delivered',
                    'Your order has been delivered',
                    true,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (_order.status == 'Dispatched')
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening tracking map...')),
                  );
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Track on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(String title, String description, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
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
      label: Text(
        paymentStatus,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  String _getDeliveryInfo(OrderProduct product) {
    switch (product.delivery) {
      case 'PERPIECE':
        return 'Per piece (\$${product.deliveryPrice.toStringAsFixed(2)} each)';
      case 'PERKG':
        return 'Per kg (\$${product.deliveryPrice.toStringAsFixed(2)} per kg)';
      case 'PERKM':
        return 'Per km (\$${product.deliveryPrice.toStringAsFixed(2)} per km)';
      case 'FLAT':
        return 'Flat rate (\$${product.deliveryPrice.toStringAsFixed(2)})';
      case 'FREE':
        return 'Free delivery';
      default:
        return 'Standard delivery (\$${product.deliveryPrice.toStringAsFixed(2)})';
    }
  }
}