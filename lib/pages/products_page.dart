import 'dart:async';
import 'package:bahirmart/core/services/product_service.dart';
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
import 'package:carousel_slider/carousel_slider.dart' as carousel
    hide CarouselController;
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
  bool _isLoading = true;

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

  final productService = ProductService();

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final ads = await productService.fetchAds();
      final products = await productService.fetchProducts();
      final categories = await productService.fetchCategories();

      if (!mounted) return;

      setState(() {
        _ads = ads;
        _products = products;
        _categories = categories;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _ads = [];
        _products = [];
        _categories = [];
        _filteredProducts = [];
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Category filter
        if (_selectedCategoryId != null &&
            product.category.categoryId != _selectedCategoryId) {
          return false;
        }

        // Search phrase filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          bool matchesName = product.productName.toLowerCase().contains(searchLower) ?? false;
          bool matchesDescription = product.description.toLowerCase().contains(searchLower) ?? false;
          if (!matchesName && !matchesDescription) {
            return false;
          }
        }

        // Price range filter
        if (product.price! < _priceRange.start ||
            product.price! > _priceRange.end) {
          return false;
        }
      
        // Rating filter
        if (product.review?.isNotEmpty ?? false) {
          final avgRating =
              product.review!.map((r) => r.rating ?? 0).reduce((a, b) => a + b) /
                  product.review!.length;
          if (avgRating < _ratingRange.start || avgRating > _ratingRange.end) {
            return false;
          }
        } else if (_ratingRange.start > 0) {
          return false; // Exclude products with no reviews if rating filter is applied
        }

        // Quantity filter
        if (product.quantity! < _quantityRange.start ||
            product.quantity! > _quantityRange.end) {
          return false;
        }
      
        // Delivery type filter
        if (_selectedDeliveryType != null &&
            product.delivery != _selectedDeliveryType) {
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
              child: Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                      label: Text(category.name ?? 'Unknown'),
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
              child: Text('Delivery Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Wrap(
              spacing: 8.0,
              children:
                  ['FLAT', 'PERPIECE', 'PERKG', 'FREE', 'PERKM'].map((type) {
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
              child: Text('Price Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: Text('Rating Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RangeSlider(
              values: _ratingRange,
              min: 0,
              max: 5,
              divisions: 10,
              labels: RangeLabels(
                _ratingRange.start.toStringAsFixed(1),
                _ratingRange.end.toStringAsFixed(1),
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
              child: Text('Quantity Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BahirMartAppBar(title: widget.title),
      body: _isLoading
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategoryId =
                                  _selectedCategoryId == category.id
                                      ? null
                                      : category.id;
                              _applyFilters();
                            });
                          },
                          child: Text(
                            category.name ?? 'Unknown',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium),
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
                        icon: Icon(_isFilterOpen
                            ? Icons.filter_list_off
                            : Icons.filter_list),
                        label: Text(
                            _isFilterOpen ? 'Hide Filters' : 'Show Filters'),
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
                            padding:
                                const EdgeInsets.all(AppSizes.paddingMedium),
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
                                  child: Text(
                                      'No products found matching your criteria'),
                                )
                              : MasonryGridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                        product: _filteredProducts[index]);
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
              mini: true,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 1),
    );
  }
}