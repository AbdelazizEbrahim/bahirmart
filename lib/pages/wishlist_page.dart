import 'package:bahirmart/components/app_bar.dart';
import 'package:bahirmart/components/bottom_navigation_bar.dart';
import 'package:bahirmart/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:bahirmart/core/services/wishlist_service.dart';

class WishlistPage extends StatefulWidget {
  final String userId;
  const WishlistPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishlist = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    setState(() => isLoading = true);
    try {
      wishlist = await WishlistService.fetchWishlist(widget.userId);
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }

  Future<void> removeItem(String productId) async {
    try {
      await WishlistService.removeFromWishlist(widget.userId, productId);
      setState(() {
        wishlist.removeWhere((item) => item['id'] == productId);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BahirMartAppBar(title: 'Profile'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlist.isEmpty
              ? const Center(child: Text('Your wishlist is empty.'))
              : ListView.builder(
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final item = wishlist[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: item),
                          ),
                        );
                      },
                      leading:
                          Image.network(item['image'], width: 50, height: 50),
                      title: Text(item['name']),
                      subtitle: Text('\$${item['price']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeItem(item['id']),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const BahirMartBottomNavigationBar(currentIndex: 4),
    );
  }
}
