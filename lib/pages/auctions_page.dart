import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_card.dart';
import '../models//auctions.dart';
import 'auction_detail_page.dart';

class AuctionsPage extends StatefulWidget {
  @override
  _AuctionsPageState createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage> {
  Future<List<Auction>> _fetchAuctions() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Auction(
        id: '1',
        auctionTitle: 'Vintage Watch Auction',
        merchantName: 'Classic Collectibles',
        category: 'Jewelry',
        description: 'A rare vintage watch.',
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

  String _calculateTimeLeft(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);
    if (difference.isNegative) return 'Ended';
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return '${hours}h ${minutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<Auction>>(
        future: _fetchAuctions(),
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
                  Text('Error loading auctions', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final auctions = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: auctions.length,
              itemBuilder: (context, index) {
                final auction = auctions[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuctionDetailPage(auction: auction),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: auction.itemImg.isNotEmpty
                              ? Image.network(auction.itemImg[0], fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported, size: 50),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auction.auctionTitle ?? 'Auction ${auction.id}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                auction.merchantName,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '\$${auction.startingPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _calculateTimeLeft(auction.endTime),
                                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}