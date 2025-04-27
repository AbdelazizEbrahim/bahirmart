import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_card.dart';
import '../models/product.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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
        review: [
          Review(customerId: 'u1', comment: 'Great sound!', rating: 5, createdDate: DateTime.now()),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<Product>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GridView.builder(
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading products', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final products = snapshot.data!;
            return GridView.builder(
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
    );
  }
}