import '../../models/product_model.dart';

class PriceComparisonItem {
  final String productName;
  final String storeName;
  final double mrp;
  final double price;
  final String location;
  final String? deliveryTime;
  final bool isOnline;

  PriceComparisonItem({
    required this.productName,
    required this.storeName,
    required this.mrp,
    required this.price,
    required this.location,
    this.deliveryTime,
    required this.isOnline,
  });

  double get discountPercentage {
    return ((mrp - price) / mrp * 100);
  }
}

class SearchData {
  // Product suggestions with MRP
  static final List<ProductModel> productSuggestions = [
    ProductModel(
      id: 'iphone-15-pro',
      name: 'iPhone 15 Pro 128GB',
      category: 'Smartphones',
      imageUrl: '',
      mrp: 134900,
    ),
    ProductModel(
      id: 'samsung-s24-ultra',
      name: 'Samsung Galaxy S24 Ultra',
      category: 'Smartphones',
      imageUrl: '',
      mrp: 129999,
    ),
    ProductModel(
      id: 'sony-4k-tv',
      name: 'Sony 55" 4K Smart TV',
      category: 'Electronics',
      imageUrl: '',
      mrp: 89990,
    ),
    ProductModel(
      id: 'samsung-tv',
      name: 'Samsung Crystal 4K UHD Smart TV 55"',
      category: 'Electronics',
      imageUrl: '',
      mrp: 54900,
    ),
    ProductModel(
      id: 'macbook-pro',
      name: 'MacBook Pro 14" M3',
      category: 'Laptops',
      imageUrl: '',
      mrp: 169900,
    ),
    ProductModel(
      id: 'dell-xps',
      name: 'Dell XPS 13',
      category: 'Laptops',
      imageUrl: '',
      mrp: 119990,
    ),
  ];

  static List<ProductModel> getFilteredSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return productSuggestions.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).take(10).toList();
  }

  static List<StoreProductModel> getStoreResults(String productId) {
    final product = productSuggestions.firstWhere(
      (p) => p.id == productId,
      orElse: () => productSuggestions.first,
    );

    final mrp = product.mrp;

    return [
      // Offline stores with different prices
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Tech World - Coochbehar',
        mrp: mrp,
        price: mrp - 4000, // ₹4000 discount
        distance: '2.5 km',
        location: 'Rajbari, Coochbehar',
        isOnline: false,
        storeId: 'store-1',
        rating: 4.5,
        reviewCount: 142,
        phoneNumber: '+919876543210',
        latitude: 26.3242,
        longitude: 89.4473,
        travelTime: '8 mins',
        openingTime: '10:00 AM - 9:00 PM',
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Mobile Hub - Coochbehar',
        mrp: mrp,
        price: mrp - 2500, // ₹2500 discount
        distance: '3.8 km',
        location: 'College Road, Coochbehar',
        isOnline: false,
        storeId: 'store-2',
        rating: 4.3,
        reviewCount: 98,
        phoneNumber: '+919876543211',
        latitude: 26.3282,
        longitude: 89.4523,
        travelTime: '12 mins',
        openingTime: '9:30 AM - 8:30 PM',
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Electronics Mart - Kolkata',
        mrp: mrp,
        price: mrp - 5000, // ₹5000 discount (best offline)
        distance: '145 km',
        location: 'College Street, Kolkata',
        isOnline: false,
        storeId: 'store-3',
        rating: 4.7,
        reviewCount: 256,
        phoneNumber: '+919876543212',
        openingTime: '10:00 AM - 10:00 PM',
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Digital Zone - Siliguri',
        mrp: mrp,
        price: mrp - 3500, // ₹3500 discount
        distance: '85 km',
        location: 'Hill Cart Road, Siliguri',
        isOnline: false,
        storeId: 'store-4',
        rating: 4.4,
        reviewCount: 187,
        phoneNumber: '+919876543213',
        openingTime: '9:00 AM - 9:00 PM',
      ),
      
      // Online stores with different prices
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Amazon India',
        mrp: mrp,
        price: mrp - 6000, // ₹6000 discount (best overall)
        deliveryDate: 'Tomorrow',
        isOnline: true,
        storeId: 'online-1',
        rating: 4.6,
        reviewCount: 1842,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Flipkart',
        mrp: mrp,
        price: mrp - 5500, // ₹5500 discount
        deliveryDate: 'In 2 days',
        isOnline: true,
        storeId: 'online-2',
        rating: 4.5,
        reviewCount: 1523,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Croma Online',
        mrp: mrp,
        price: mrp - 4500, // ₹4500 discount
        deliveryDate: 'In 3 days',
        isOnline: true,
        storeId: 'online-3',
        rating: 4.4,
        reviewCount: 876,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Reliance Digital',
        mrp: mrp,
        price: mrp - 4000, // ₹4000 discount
        deliveryDate: 'In 2 days',
        isOnline: true,
        storeId: 'online-4',
        rating: 4.3,
        reviewCount: 654,
      ),
    ]..sort((a, b) => a.price.compareTo(b.price)); // Sort by actual price
  }

  // Featured comparisons with MRP
  static final List<List<PriceComparisonItem>> featuredComparisons = [
    // Laptop Comparison
    [
      PriceComparisonItem(
        productName: 'ASUS VivoBook 15',
        storeName: 'Tech Store Coochbehar',
        mrp: 50000,
        price: 45000,
        location: 'Rajbari Road',
        isOnline: false,
      ),
      PriceComparisonItem(
        productName: 'ASUS VivoBook 15',
        storeName: 'XYZ Electronics',
        mrp: 50000,
        price: 45500,
        location: 'College Street',
        isOnline: false,
      ),
      PriceComparisonItem(
        productName: 'ASUS VivoBook 15',
        storeName: 'Amazon',
        mrp: 50000,
        price: 43999,
        location: 'Online',
        deliveryTime: '3 days',
        isOnline: true,
      ),
      PriceComparisonItem(
        productName: 'ASUS VivoBook 15',
        storeName: 'Flipkart',
        mrp: 50000,
        price: 44499,
        location: 'Online',
        deliveryTime: '2 days',
        isOnline: true,
      ),
    ],
    
    // TV Comparison
    [
      PriceComparisonItem(
        productName: 'Samsung Crystal 4K UHD Smart TV 55"',
        storeName: 'Tech World',
        mrp: 54900,
        price: 50000,
        location: 'Main Market',
        isOnline: false,
      ),
      PriceComparisonItem(
        productName: 'Samsung Crystal 4K UHD Smart TV 55"',
        storeName: 'Electronics Hub',
        mrp: 54900,
        price: 50900,
        location: 'City Center',
        isOnline: false,
      ),
      PriceComparisonItem(
        productName: 'Samsung Crystal 4K UHD Smart TV 55"',
        storeName: 'Amazon',
        mrp: 54900,
        price: 48990,
        location: 'Online',
        deliveryTime: 'Tomorrow',
        isOnline: true,
      ),
      PriceComparisonItem(
        productName: 'Samsung Crystal 4K UHD Smart TV 55"',
        storeName: 'Flipkart',
        mrp: 54900,
        price: 49499,
        location: 'Online',
        deliveryTime: '2 days',
        isOnline: true,
      ),
    ],
  ];
}
