import 'dart:async';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel
    hide CarouselController;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:bahirmart/components/ad_card.dart';
import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/components/category_card.dart';
import 'package:bahirmart/components/product_card.dart';
import 'package:bahirmart/components/search_bar.dart' as custom;
import 'package:bahirmart/components/toggle_button.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;
import 'package:bahirmart/core/models/category_model.dart' as cat;
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:bahirmart/main.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedToggleIndex = 0;
  String? _selectedCategoryId;
  List<ad_model.Ad> _ads = [];
  List<prod_model.Product> _products = [];
  List<cat.Category> _categories = [];
  User? _user;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isLoading = true;

  // Add section keys for scrolling
  final Map<String, GlobalKey> _sectionKeys = {
    'best_seller': GlobalKey(),
    'top_rated': GlobalKey(),
    'new_arrival': GlobalKey(),
  };

  // Add category section keys
  late final Map<String, GlobalKey> _categorySectionKeys;

  @override
  void initState() {
    super.initState();
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

  void _scrollToSection(String sectionKey) {
    final context = _sectionKeys[sectionKey]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToCategory(String categoryId) {
    final context = _categorySectionKeys[categoryId]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Mock API Calls
  Future<List<prod_model.Product>> _fetchProducts(String type) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final mockProducts = List.generate(20, (index) {
      final catIndex = index % 5;
      final hasOffer = index % 5 == 0 || index % 7 == 0;

      return prod_model.Product(
        id: 'product_${index + 1}',
        merchantDetail: prod_model.MerchantDetail(
          merchantId: 'merchant_${catIndex + 1}',
          merchantName: [
            'TechTrend',
            'StyleHub',
            'HomeHaven',
            'SportZone',
            'BookNook'
          ][catIndex],
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
        ][index],
        category: prod_model.ProductCategory(
          categoryId: 'cat_${catIndex + 1}',
          categoryName: [
            'Electronics',
            'Fashion',
            'Home & Garden',
            'Sports',
            'Books'
          ][catIndex],
        ),
        price: 19.99 + index * 10,
        quantity: 100 - index * 2,
        soldQuantity: index * 5,
        description: 'High-quality ${[
          'earbuds with noise cancellation',
          'jeans with slim fit',
          'table with minimalist design',
          'mat for yoga enthusiasts',
          'novel with rich storytelling',
          'watch with fitness tracking',
          'scarf with elegant design',
          'tools for gardening',
          'ball for soccer matches',
          'recipes for home cooking',
          'speaker with deep bass',
          'sneakers for daily wear',
          'lamp for cozy ambiance',
          'tracker for workouts',
          'novel with suspenseful plot',
          'stand for ergonomic setup',
          'sunglasses with UV protection',
          'plant for home decor',
          'goggles for swimming',
          'poetry with deep emotions'
        ][index]}.',
        images: ['https://picsum.photos/150/150?random=${index + 1}'],
        variant: [
          'Color: ${['Blue', 'Black', 'Brown', 'Green', 'Red'][catIndex]}'
        ],
        size: [
          '${['Standard', 'L', 'Medium', 'One Size', 'Paperback'][catIndex]}'
        ],
        brand: [
          'TechBrand',
          'StyleCo',
          'HomeCraft',
          'SportPro',
          'LitPress'
        ][catIndex],
        location: prod_model.Location(
          type: 'Point',
          coordinates: [38.8951 + index * 0.005, -77.0364 + index * 0.005],
        ),
        review: [
          prod_model.Review(
            customerId: 'cust_${index + 1}',
            comment: 'Really satisfied with this!',
            rating: 3 + (index % 3),
            createdDate: DateTime.now().subtract(Duration(days: index + 1)),
          ),
        ],
        delivery: ['PERPIECE', 'PERKG', 'FREE', 'PERKM'][index % 4],
        deliveryPrice: 4.99,
        kilogramPerPrice: index % 2 == 0 ? 1.5 : null,
        kilometerPerPrice: index % 3 == 0 ? 2.0 : null,
        isBanned: false,
        isDeleted: false,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        offer: hasOffer
            ? prod_model.Offer(
                price: (19.99 + index * 10) * 0.8,
                offerEndDate:
                    DateTime.now().add(Duration(days: 7 + index % 14)),
              )
            : null,
      );
    });

    // Sort products based on type
    List<prod_model.Product> sortedProducts;
    switch (type) {
      case 'best_seller':
        sortedProducts = mockProducts
          ..sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
        break;
      case 'top_rated':
        sortedProducts = mockProducts
          ..sort((a, b) => (b.review?.first.rating ?? 0)
              .compareTo(a.review?.first.rating ?? 0));
        break;
      case 'new_arrival':
        sortedProducts = mockProducts
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        sortedProducts = mockProducts;
    }

    return sortedProducts;
  }

  Future<List<prod_model.Product>> _fetchProductsByCategory(
      String categoryId) async {
    final allProducts = await _fetchProducts('all');
    return allProducts
        .where((p) => p.category.categoryId == categoryId)
        .toList();
  }

  Future<List<cat.Category>> _fetchCategories() async {
    await Future.delayed(const Duration(seconds: 1));
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

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);

      final categories = await _fetchCategories();
      final products = await _fetchProducts('best_seller');

      setState(() {
        _categories = categories;
        _products = products.take(12).toList();
        _categorySectionKeys = {
          for (var category in _categories) category.id: GlobalKey(),
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToProducts(String categoryId) {
    Navigator.pushNamed(
      context,
      '/products',
      arguments: {
        'categoryId': categoryId,
        'title': _categories.firstWhere((cat) => cat.id == categoryId).name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BahirMartAppBar(title: 'BahirMart'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const custom.SearchBar(),
                  // Labels for Best Seller, Top Rated, and New Arrival
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium),
                      children: [
                        TextButton(
                          onPressed: () => _scrollToSection('best_seller'),
                          child: Text(
                            'Best Seller',
                            style: TextStyle(
                              color: _selectedToggleIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: _selectedToggleIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => _scrollToSection('top_rated'),
                          child: Text(
                            'Top Rated',
                            style: TextStyle(
                              color: _selectedToggleIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: _selectedToggleIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => _scrollToSection('new_arrival'),
                          child: Text(
                            'New Arrival',
                            style: TextStyle(
                              color: _selectedToggleIndex == 2
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: _selectedToggleIndex == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Categories at the top
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: TextButton(
                            onPressed: () => _scrollToCategory(category.id),
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
                  // Best Seller Section
                  Container(
                    key: _sectionKeys['best_seller'],
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Best Sellers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<prod_model.Product>>(
                          future: _fetchProducts('best_seller'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            final products = snapshot.data ?? [];
                            return MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Top Rated Section
                  Container(
                    key: _sectionKeys['top_rated'],
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Rated',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<prod_model.Product>>(
                          future: _fetchProducts('top_rated'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            final products = snapshot.data ?? [];
                            return MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // New Arrivals Section
                  Container(
                    key: _sectionKeys['new_arrival'],
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Arrivals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<prod_model.Product>>(
                          future: _fetchProducts('new_arrival'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            final products = snapshot.data ?? [];
                            return MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Category Sections
                  ..._categories.map((category) {
                    return Container(
                      key: _categorySectionKeys[category.id],
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                onPressed: () =>
                                    _navigateToProducts(category.id),
                                child: const Text('See More'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<List<prod_model.Product>>(
                            future: _fetchProductsByCategory(category.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              final products = snapshot.data ?? [];
                              return MasonryGridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(product: products[index]);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
              mini: true,
            )
          : null,
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 0),
    );
  }
}
