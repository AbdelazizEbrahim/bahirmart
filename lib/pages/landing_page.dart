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
import 'package:bahirmart/core/services/landing_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final int _selectedToggleIndex = 0;
  String? _selectedCategoryId;
  List<ad_model.Ad> _ads = [];
  List<prod_model.Product> _products = [];
  List<cat.Category> _categories = [];
  Map<String, List<prod_model.Product>> _categoryProducts = {};
  User? _user;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isLoading = true;

  final Map<String, GlobalKey> _sectionKeys = {
    'best_seller': GlobalKey(),
    'top_rated': GlobalKey(),
    'new_arrival': GlobalKey(),
  };

  late final Map<String, GlobalKey> _categorySectionKeys;

  final LandingService _landingService = LandingService();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);

      // Fetch categories and products in parallel
      final categoriesFuture = _landingService.fetchCategories();
      final productsFuture = _landingService.fetchProducts();

      final categories = await categoriesFuture;
      final productsResponse = await productsFuture;

      // Create category section keys
      final categorySectionKeys = {
        for (var category in categories) category.id: GlobalKey(),
      };

      // Organize products by category
      final categoryProducts = <String, List<prod_model.Product>>{};
      for (var category in categories) {
        categoryProducts[category.id] = productsResponse.products
            .where((product) => product.category.categoryId == category.id)
            .toList();
      }

      // Fetch ads
      final ads = await _landingService.fetchAds();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _products = productsResponse.products;
        _categoryProducts = categoryProducts;
        _categorySectionKeys = categorySectionKeys;
        _ads = ads;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
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
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BahirMartAppBar(title: 'BahirMart'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initializeData,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const custom.SearchBar(),
                    if (_ads.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: carousel.CarouselSlider(
                          options: carousel.CarouselOptions(
                            height: 200.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                          ),
                          items: _ads.map((ad) {
                            return AdCard(ad: ad);
                          }).toList(),
                        ),
                      ),
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
                            future: _landingService.fetchBestSellers(),
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
                            future: _landingService.fetchTopRated(),
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
                            future: _landingService.fetchNewArrivals(),
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
                    ..._categories.map((category) {
                      final products = _categoryProducts[category.id] ?? [];
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
                            products.isEmpty
                                ? const Center(
                                    child: Text('No products available'))
                                : MasonryGridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      return ProductCard(
                                          product: products[index]);
                                    },
                                  ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 0),
    );
  }
}
