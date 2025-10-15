import '../../models/product_model.dart';

class SearchData {
  // Product suggestions (autocomplete)
  static final List<ProductModel> productSuggestions = [
    // iPhones
    ProductModel(
      id: 'iphone-15-pro',
      name: 'iPhone 15 Pro 128GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'iphone-15',
      name: 'iPhone 15 256GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'iphone-14-pro',
      name: 'iPhone 14 Pro Max 512GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'iphone-14',
      name: 'iPhone 14 128GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'iphone-13',
      name: 'iPhone 13 256GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'iphone-12',
      name: 'iPhone 12 128GB',
      category: 'Smartphones',
      imageUrl: '',
    ),
    
    // Samsung
    ProductModel(
      id: 'samsung-s24-ultra',
      name: 'Samsung Galaxy S24 Ultra',
      category: 'Smartphones',
      imageUrl: '',
    ),
    ProductModel(
      id: 'samsung-s23',
      name: 'Samsung Galaxy S23',
      category: 'Smartphones',
      imageUrl: '',
    ),
    
    // TVs
    ProductModel(
      id: 'sony-4k-tv',
      name: 'Sony 55" 4K Smart TV',
      category: 'Electronics',
      imageUrl: '',
    ),
    ProductModel(
      id: 'sony-1080p-tv',
      name: 'Sony 43" 1080p LED TV',
      category: 'Electronics',
      imageUrl: '',
    ),
    ProductModel(
      id: 'lg-oled-tv',
      name: 'LG 65" OLED 4K TV',
      category: 'Electronics',
      imageUrl: '',
    ),
    ProductModel(
      id: 'samsung-qled-tv',
      name: 'Samsung 55" QLED 4K TV',
      category: 'Electronics',
      imageUrl: '',
    ),
    
    // Laptops
    ProductModel(
      id: 'macbook-pro',
      name: 'MacBook Pro 14" M3',
      category: 'Laptops',
      imageUrl: '',
    ),
    ProductModel(
      id: 'dell-xps',
      name: 'Dell XPS 13',
      category: 'Laptops',
      imageUrl: '',
    ),
    ProductModel(
      id: 'hp-pavilion',
      name: 'HP Pavilion 15',
      category: 'Laptops',
      imageUrl: '',
    ),
  ];

  // Get filtered suggestions
  static List<ProductModel> getFilteredSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return productSuggestions.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).take(10).toList();
  }

  // Get store results for a product
  static List<StoreProductModel> getStoreResults(String productId) {
    // This would be API call in production
    return _generateMockStoreData(productId);
  }

  static List<StoreProductModel> _generateMockStoreData(String productId) {
    final product = productSuggestions.firstWhere(
      (p) => p.id == productId,
      orElse: () => productSuggestions.first,
    );

    return [
      // Offline stores
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Tech World - Coochbehar',
        price: 89999,
        distance: '2.5 km',
        location: 'Rajbari, Coochbehar',
        isOnline: false,
        storeId: 'store-1',
        rating: 4.5,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Mobile Hub - Coochbehar',
        price: 92499,
        distance: '3.8 km',
        location: 'College Road, Coochbehar',
        isOnline: false,
        storeId: 'store-2',
        rating: 4.3,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Electronics Mart - Kolkata',
        price: 88999,
        distance: '145 km',
        location: 'College Street, Kolkata',
        isOnline: false,
        storeId: 'store-3',
        rating: 4.7,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Digital Zone - Siliguri',
        price: 90999,
        distance: '85 km',
        location: 'Hill Cart Road, Siliguri',
        isOnline: false,
        storeId: 'store-4',
        rating: 4.4,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Gadget Store - Jalpaiguri',
        price: 91499,
        distance: '55 km',
        location: 'Dinbazar, Jalpaiguri',
        isOnline: false,
        storeId: 'store-5',
        rating: 4.2,
      ),
      
      // Online stores
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Amazon India',
        price: 87999,
        deliveryDate: 'Tomorrow',
        isOnline: true,
        storeId: 'online-1',
        rating: 4.6,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Flipkart',
        price: 88499,
        deliveryDate: 'In 2 days',
        isOnline: true,
        storeId: 'online-2',
        rating: 4.5,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Croma Online',
        price: 89499,
        deliveryDate: 'In 3 days',
        isOnline: true,
        storeId: 'online-3',
        rating: 4.4,
      ),
      StoreProductModel(
        productId: productId,
        productName: product.name,
        storeName: 'Reliance Digital',
        price: 89999,
        deliveryDate: 'In 2 days',
        isOnline: true,
        storeId: 'online-4',
        rating: 4.3,
      ),
    ]..sort((a, b) => a.price.compareTo(b.price)); // Sort by price
  }
}
