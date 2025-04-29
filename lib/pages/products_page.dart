import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bahirmart/components/ad_card.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/components/product_card.dart';
import 'package:bahirmart/components/search_bar.dart' as custom;
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;
import 'package:bahirmart/core/models/category_model.dart' as cat;
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:carousel_slider/carousel_slider.dart' as carousel hide CarouselController;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductsPage extends StatefulWidget {
  final String? searchPhrase;
  final String? categoryId;
  final String title;

  const ProductsPage({
    Key? key,
    this.searchPhrase,
    this.categoryId,
    required this.title,
  }) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isFilterOpen = false;

  // Data
  List<ad_model.Ad> _ads = [];
  List<prod_model.Product> _products = [];
  List<cat.Category> _categories = [];
  List<prod_model.Product> _filteredProducts = [];

  // Filter states
  String? _selectedCategoryId;
  String? _selectedDeliveryType;
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _ratingRange = const RangeValues(0, 5);
  RangeValues _quantityRange = const RangeValues(0, 100);

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchPhrase ?? '';
    _selectedCategoryId = widget.categoryId;
    _fetchData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      }
    } else {
      if (_showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Mock API Calls
  Future<List<ad_model.Ad>> _fetchAds() async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/ads'));
      // if (response.statusCode == 200) {
      //   return (jsonDecode(response.body) as List)
      //       .map((json) => ad_model.Ad.fromJson(json))
      //       .toList();
      // }
      await Future.delayed(const Duration(seconds: 1));
      return _generateMockAds();
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }

  Future<List<prod_model.Product>> _fetchProducts() async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/products'));
      // if (response.statusCode == 200) {
      //   return (jsonDecode(response.body) as List)
      //       .map((json) => prod_model.Product.fromJson(json))
      //       .toList();
      // }
      await Future.delayed(const Duration(seconds: 1));
      return _generateMockProducts();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<cat.Category>> _fetchCategories() async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/categories'));
      // if (response.statusCode == 200) {
      //   return (jsonDecode(response.body) as List)
      //       .map((json) => cat.Category.fromJson(json))
      //       .toList();
      // }
      await Future.delayed(const Duration(seconds: 1));
      return _generateMockCategories();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> _fetchData() async {
    try {
      final ads = await _fetchAds();
      final products = await _fetchProducts();
      final categories = await _fetchCategories();
      setState(() {
        _ads = ads;
        _products = products;
        _categories = categories;
        _applyFilters();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Category filter
        if (_selectedCategoryId != null && product.category.categoryId != _selectedCategoryId) {
          return false;
        }

        // Search phrase filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          if (!product.productName.toLowerCase().contains(searchLower) &&
              !product.description.toLowerCase().contains(searchLower)) {
            return false;
          }
        }

        // Price range filter
        if (product.price < _priceRange.start || product.price > _priceRange.end) {
          return false;
        }

        // Rating filter
        if (product.review.isNotEmpty) {
          final avgRating = product.review.map((r) => r.rating).reduce((a, b) => a + b) / product.review.length;
          if (avgRating < _ratingRange.start || avgRating > _ratingRange.end) {
            return false;
          }
        }

        // Quantity filter
        if (product.quantity < _quantityRange.start || product.quantity > _quantityRange.end) {
          return false;
        }

        // Delivery type filter
        if (_selectedDeliveryType != null && product.delivery != _selectedDeliveryType) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = widget.categoryId;
      _selectedDeliveryType = null;
      _priceRange = const RangeValues(0, 1000);
      _ratingRange = const RangeValues(0, 5);
      _quantityRange = const RangeValues(0, 100);
      _applyFilters();
    });
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isFilterOpen ? 400 : 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                          _applyFilters();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            // Delivery Type Filter
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Delivery Type', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Wrap(
              spacing: 8.0,
              children: ['FLAT', 'PERPIECE', 'PERKG', 'FREE', 'PERKM'].map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedDeliveryType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDeliveryType = selected ? type : null;
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(),

            // Price Range Filter
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                  _applyFilters();
                });
              },
            ),
            const Divider(),

            // Rating Range Filter
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Rating Range', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RangeSlider(
              values: _ratingRange,
              min: 0,
              max: 5,
              divisions: 10,
              labels: RangeLabels(
                '${_ratingRange.start.toStringAsFixed(1)}',
                '${_ratingRange.end.toStringAsFixed(1)}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _ratingRange = values;
                  _applyFilters();
                });
              },
            ),
            const Divider(),

            // Quantity Range Filter
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Quantity Range', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RangeSlider(
              values: _quantityRange,
              min: 0,
              max: 100,
              divisions: 20,
              labels: RangeLabels(
                '${_quantityRange.start.round()}',
                '${_quantityRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _quantityRange = values;
                  _applyFilters();
                });
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _resetFilters,
                child: const Text('Reset Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock Data Generation
  List<ad_model.Ad> _generateMockAds() {
    final categories = [
      prod_model.ProductCategory(categoryId: 'cat_1', categoryName: 'Electronics'),
      prod_model.ProductCategory(categoryId: 'cat_2', categoryName: 'Fashion'),
      prod_model.ProductCategory(categoryId: 'cat_3', categoryName: 'Home & Garden'),
      prod_model.ProductCategory(categoryId: 'cat_4', categoryName: 'Sports'),
      prod_model.ProductCategory(categoryId: 'cat_5', categoryName: 'Books'),
    ];

    return List.generate(5, (index) {
      // Determine if this product has an offer (all ads have offers)
      final offerPrice = 699.99 - (index * 50);
      final offerEndDate = DateTime.now().add(Duration(days: 7 - index));
      
      // Set delivery-specific prices
      final deliveryTypes = ['FLAT', 'PERPIECE', 'PERKG', 'FREE', 'PERKM'];
      final deliveryType = deliveryTypes[index % deliveryTypes.length];
      final deliveryPrice = 5.99 + (index % 3);
      final kilogramPerPrice = deliveryType == 'PERKG' ? 3.99 + (index % 3) : null;
      final kilometerPerPrice = deliveryType == 'PERKM' ? 2.99 + (index % 3) : null;
      
      return ad_model.Ad(
        id: 'ad_${index + 1}',
        product: prod_model.Product(
          id: 'product_ad_${index + 1}',
          merchantDetail: prod_model.MerchantDetail(
            merchantId: 'merchant_${index + 1}',
            merchantName: ['TechTrend', 'StyleHub', 'HomeHaven', 'SportZone', 'BookNook'][index],
            merchantEmail: 'merchant${index + 1}@bahirmart.com',
          ),
          productName: [
            'Smartphone X Pro',
            'Leather Jacket',
            'Ceramic Planter',
            'Pro Tennis Racket',
            'Sci-Fi Novel Collection',
          ][index],
          category: categories[index],
          price: [699.99, 149.99, 29.99, 89.99, 39.99][index],
          quantity: 50,
          soldQuantity: (index + 1) * 10,
          description: 'Premium ${['smartphone with 5G', 'jacket with modern fit', 'planter for indoor plants', 'racket for professionals', 'collection of bestselling novels'][index]}.',
          images: ['https://picsum.photos/300/200?random=${index + 1}'],
          variant: ['Color: ${['Black', 'Brown', 'White', 'Red', 'Blue'][index]}'],
          size: ['${['128GB', 'M', 'Small', 'Standard', 'Hardcover'][index]}'],
          brand: ['TechBrand', 'StyleCo', 'HomeCraft', 'SportPro', 'LitPress'][index],
          location: prod_model.Location(type: 'Point', coordinates: [38.8951 + index * 0.01, -77.0364 + index * 0.01]),
          review: [
            prod_model.Review(
              customerId: 'cust_${index + 1}',
              comment: 'Great product!',
              rating: 4 + (index % 2),
              createdDate: DateTime.now().subtract(Duration(days: index + 1)),
            ),
          ],
          delivery: deliveryType,
          deliveryPrice: deliveryPrice,
          kilogramPerPrice: kilogramPerPrice,
          kilometerPerPrice: kilometerPerPrice,
          isBanned: false,
          isDeleted: false,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          offer: prod_model.Offer(
            price: offerPrice,
            offerEndDate: offerEndDate,
          ),
        ),
        merchantDetail: ad_model.MerchantDetail(
          merchantId: 'merchant_${index + 1}',
          merchantName: ['TechTrend', 'StyleHub', 'HomeHaven', 'SportZone', 'BookNook'][index],
          merchantEmail: 'merchant${index + 1}@bahirmart.com',
        ),
        startsAt: DateTime.now().subtract(Duration(days: index)),
        endsAt: DateTime.now().add(Duration(days: 7 - index)),
        adPrice: 100.0 + index * 20,
        txRef: 'tx_ad_${index + 1}',
        approvalStatus: 'APPROVED',
        paymentStatus: 'PAID',
        isActive: true,
        isHome: true,
        adRegion: 'Region ${index + 1}',
        location: ad_model.Location(type: 'Point', coordinates: [38.8951 + index * 0.01, -77.0364 + index * 0.01]),
      );
    });
  }

  List<prod_model.Product> _generateMockProducts() {
    final categories = [
      prod_model.ProductCategory(categoryId: 'cat_1', categoryName: 'Electronics'),
      prod_model.ProductCategory(categoryId: 'cat_2', categoryName: 'Fashion'),
      prod_model.ProductCategory(categoryId: 'cat_3', categoryName: 'Home & Garden'),
      prod_model.ProductCategory(categoryId: 'cat_4', categoryName: 'Sports'),
      prod_model.ProductCategory(categoryId: 'cat_5', categoryName: 'Books'),
    ];

    return List.generate(50, (index) {
      final catIndex = index % 5;
      final deliveryTypes = ['FLAT', 'PERPIECE', 'PERKG', 'FREE', 'PERKM'];
      final deliveryType = deliveryTypes[index % deliveryTypes.length];
      
      // Determine if this product has an offer (about 30% of products)
      final hasOffer = index % 3 == 0;
      final offerPrice = hasOffer ? 19.99 + index * 5 : null;
      final offerEndDate = hasOffer ? DateTime.now().add(Duration(days: 7 + index % 14)) : null;
      
      // Set delivery-specific prices
      final deliveryPrice = 4.99 + (index % 3);
      final kilogramPerPrice = deliveryType == 'PERKG' ? 2.99 + (index % 3) : null;
      final kilometerPerPrice = deliveryType == 'PERKM' ? 1.99 + (index % 3) : null;
      
      return prod_model.Product(
        id: 'product_${index + 1}',
        merchantDetail: prod_model.MerchantDetail(
          merchantId: 'merchant_${catIndex + 1}',
          merchantName: ['TechTrend', 'StyleHub', 'HomeHaven', 'SportZone', 'BookNook'][catIndex],
          merchantEmail: 'merchant${catIndex + 1}@bahirmart.com',
        ),
        productName: [
          'Wireless Earbuds',
          'Denim Jeans',
          'Wooden Coffee Table',
          'Yoga Mat',
          'Historical Fiction',
          'Smart Watch',
          'Silk Scarf',
          'Garden Tools Set',
          'Soccer Ball',
          'Cookbook',
          'Bluetooth Speaker',
          'Sneakers',
          'Decorative Lamp',
          'Fitness Tracker',
          'Mystery Novel',
          'Laptop Stand',
          'Sunglasses',
          'Indoor Plant',
          'Swimming Goggles',
          'Poetry Collection',
        ][index % 20],
        category: categories[catIndex],
        price: 19.99 + index * 10,
        quantity: 100 - index * 2,
        soldQuantity: index * 5,
        description: 'High-quality ${['earbuds with noise cancellation', 'jeans with slim fit', 'table with minimalist design', 'mat for yoga enthusiasts', 'novel with rich storytelling', 'watch with fitness tracking', 'scarf with elegant design', 'tools for gardening', 'ball for soccer matches', 'recipes for home cooking', 'speaker with deep bass', 'sneakers for daily wear', 'lamp for cozy ambiance', 'tracker for workouts', 'novel with suspenseful plot', 'stand for ergonomic setup', 'sunglasses with UV protection', 'plant for home decor', 'goggles for swimming', 'poetry with deep emotions'][index % 20]}.',
        images: ['https://picsum.photos/150/150?random=${index + 1}'],
        variant: ['Color: ${['Blue', 'Black', 'Brown', 'Green', 'Red'][catIndex]}'],
        size: ['${['Standard', 'L', 'Medium', 'One Size', 'Paperback'][catIndex]}'],
        brand: ['TechBrand', 'StyleCo', 'HomeCraft', 'SportPro', 'LitPress'][catIndex],
        location: prod_model.Location(type: 'Point', coordinates: [38.8951 + index * 0.005, -77.0364 + index * 0.005]),
        review: List.generate(
          3,
          (reviewIndex) => prod_model.Review(
            customerId: 'cust_${index}_${reviewIndex}',
            comment: 'Great product!',
            rating: 3 + (index + reviewIndex) % 3,
            createdDate: DateTime.now().subtract(Duration(days: index + reviewIndex)),
          ),
        ),
        delivery: deliveryType,
        deliveryPrice: deliveryPrice,
        kilogramPerPrice: kilogramPerPrice,
        kilometerPerPrice: kilometerPerPrice,
        isBanned: false,
        isDeleted: false,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        offer: hasOffer ? prod_model.Offer(
          price: offerPrice!,
          offerEndDate: offerEndDate,
        ) : null,
      );
    });
  }

  List<cat.Category> _generateMockCategories() {
    return [
      cat.Category(
        id: 'cat_1',
        name: 'Electronics',
        description: 'Gadgets and tech accessories',
        createdBy: 'admin',
        isDeleted: false,
      ),
      cat.Category(
        id: 'cat_2',
        name: 'Fashion',
        description: 'Clothing and accessories',
        createdBy: 'admin',
        isDeleted: false,
      ),
      cat.Category(
        id: 'cat_3',
        name: 'Home & Garden',
        description: 'Furniture and decor',
        createdBy: 'admin',
        isDeleted: false,
      ),
      cat.Category(
        id: 'cat_4',
        name: 'Sports',
        description: 'Equipment and activewear',
        createdBy: 'admin',
        isDeleted: false,
      ),
      cat.Category(
        id: 'cat_5',
        name: 'Books',
        description: 'Novels and educational books',
        createdBy: 'admin',
        isDeleted: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(title: widget.title),
      body: _ads.isEmpty || _products.isEmpty || _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            ),
                          ),
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),

                // Categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategoryId = _selectedCategoryId == category.id ? null : category.id;
                              _applyFilters();
                            });
                          },
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: _selectedCategoryId == category.id
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: _selectedCategoryId == category.id
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Filter Toggle Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredProducts.length} products found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isFilterOpen = !_isFilterOpen;
                          });
                        },
                        icon: Icon(_isFilterOpen ? Icons.filter_list_off : Icons.filter_list),
                        label: Text(_isFilterOpen ? 'Hide Filters' : 'Show Filters'),
                      ),
                    ],
                  ),
                ),

                // Filter Section
                _buildFilterSection(),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Ads Carousel
                        if (_ads.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingMedium),
                            child: carousel.CarouselSlider(
                              options: carousel.CarouselOptions(
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                aspectRatio: 2.0,
                                enlargeCenterPage: true,
                              ),
                              items: _ads.map((ad) {
                                return AdCard(ad: ad);
                              }).toList(),
                            ),
                          ),

                        // Products Grid
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          child: _filteredProducts.isEmpty
                              ? const Center(
                                  child: Text('No products found matching your criteria'),
                                )
                              : MasonryGridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(product: _filteredProducts[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
              mini: true,
            )
          : null,
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 1),
    );
  }
}
