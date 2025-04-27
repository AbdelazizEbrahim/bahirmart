import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/auction_card.dart';
import '../widgets/shimmer_card.dart';
import '../models/product.dart';
import '../models/auctions.dart';
import 'product_detail_page.dart';
import 'auction_detail_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentAdIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentAdIndex < 4) {
        _currentAdIndex++;
      } else {
        _currentAdIndex = 0;
      }
      _pageController.animateToPage(
        _currentAdIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProducts() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Product(
        id: '1',
        merchantDetail: MerchantDetail(merchantId: 'm1', merchantName: 'Sony Store', merchantEmail: 'sony@example.com'),
        productName: 'Wireless Headphones',
        category: Category(categoryId: 'c1', categoryName: 'Electronics'),
        price: 99.99,
        quantity: 10,
        description: 'High-quality wireless headphones.',
        images: ['https://example.com/headphones.jpg'],
        brand: 'Sony',
        location: Location(coordinates: [0, 0]),
        delivery: 'FREE',
        deliveryPrice: 0.0,
        createdAt: DateTime.now(),
      ),
      Product(
        id: '2',
        merchantDetail: MerchantDetail(merchantId: 'm2', merchantName: 'Samsung Store', merchantEmail: 'samsung@example.com'),
        productName: 'Smartphone',
        category: Category(categoryId: 'c1', categoryName: 'Electronics'),
        price: 499.99,
        quantity: 5,
        description: 'Latest smartphone model.',
        images: [],
        brand: 'Samsung',
        location: Location(coordinates: [0, 0]),
        delivery: 'FLAT',
        deliveryPrice: 5.99,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<List<Auction>> _fetchAuctions() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Auction(
        id: '1',
        auctionTitle: 'Vintage Watch Auction',
        merchantName: 'Classic Collectibles',
        category: 'Jewelry',
        condition: 'used',
        startTime: DateTime.now().subtract(Duration(days: 1)),
        endTime: DateTime.now().add(Duration(days: 2)),
        itemImg: ['https://example.com/watch.jpg'],
        startingPrice: 200.0,
        reservedPrice: 300.0,
        bidIncrement: 10.0,
        remainingQuantity: 1,
        createdAt: DateTime.now(),
      ),
      Auction(
        id: '2',
        merchantName: 'Tech Deals',
        category: 'Electronics',
        condition: 'new',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 12)),
        itemImg: ['https://example.com/laptop.jpg'],
        startingPrice: 500.0,
        reservedPrice: 600.0,
        remainingQuantity: 1,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Carousel
            Container(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final mockAd = {
                    'image': 'https://example.com/ad${index + 1}.jpg',
                    'title': 'Featured Product ${index + 1}',
                  };
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(mockAd['image']!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) => Icon(Icons.error),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mockAd['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text('Buy Now', style: TextStyle(color: Colors.white)),
                                  ),
                                  SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text('More', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Products Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Featured Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Product>>(
              future: _fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => ShimmerProductCard(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading products'));
                } else {
                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: products[index]),
                            ),
                          );
                        },
                        child: ProductCard(product: products[index]),
                      );
                    },
                  );
                }
              },
            ),
            // Auctions Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Featured Auctions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Auction>>(
              future: _fetchAuctions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => ShimmerProductCard(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading auctions'));
                } else {
                  final auctions = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: auctions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuctionDetailPage(auction: auctions[index]),
                            ),
                          );
                        },
                        child: AuctionCard(auction: auctions[index]),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}