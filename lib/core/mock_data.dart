import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:bahirmart/core/models/ad_model.dart' as ad_model;
import 'package:bahirmart/core/models/category_model.dart' as cat_model;

class MockData {
  static List<cat_model.Category> get mockCategories => [
        cat_model.Category(
          id: 'cat_1',
          name: 'Electronics',
          description: 'Gadgets and tech accessories',
          createdBy: 'admin',
          isDeleted: false,
        ),
        cat_model.Category(
          id: 'cat_2',
          name: 'Fashion',
          description: 'Clothing and accessories',
          createdBy: 'admin',
          isDeleted: false,
        ),
        cat_model.Category(
          id: 'cat_3',
          name: 'Home & Garden',
          description: 'Furniture and decor',
          createdBy: 'admin',
          isDeleted: false,
        ),
        cat_model.Category(
          id: 'cat_4',
          name: 'Sports',
          description: 'Equipment and activewear',
          createdBy: 'admin',
          isDeleted: false,
        ),
        cat_model.Category(
          id: 'cat_5',
          name: 'Books',
          description: 'Novels and educational books',
          createdBy: 'admin',
          isDeleted: false,
        ),
      ];

  static List<prod_model.Product> get mockProducts =>
      List.generate(20, (index) {
        final catIndex = index % 5;
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
          delivery: 'FLAT',
          deliveryPrice: 4.99,
          isBanned: false,
          isDeleted: false,
          createdAt: DateTime.now().subtract(Duration(days: index)),
        );
      });

  static List<ad_model.Ad> get mockAds => List.generate(5, (index) {
        final product = mockProducts[index];
        return ad_model.Ad(
          id: 'ad_${index + 1}',
          product: product,
          merchantDetail: ad_model.MerchantDetail(
            merchantId: product.merchantDetail.merchantId,
            merchantName: product.merchantDetail.merchantName,
            merchantEmail: product.merchantDetail.merchantEmail,
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
          location: ad_model.Location(
            type: 'Point',
            coordinates: [38.8951 + index * 0.01, -77.0364 + index * 0.01],
          ),
        );
      });
}
