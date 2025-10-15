class ProductModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });
}

class StoreProductModel {
  final String productId;
  final String productName;
  final String storeName;
  final double price;
  final String? distance; // For offline stores
  final String? location; // For offline stores
  final String? deliveryDate; // For online stores
  final bool isOnline;
  final String storeId;
  final double? rating;

  StoreProductModel({
    required this.productId,
    required this.productName,
    required this.storeName,
    required this.price,
    this.distance,
    this.location,
    this.deliveryDate,
    required this.isOnline,
    required this.storeId,
    this.rating,
  });
}
