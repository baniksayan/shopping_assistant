class ProductModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double mrp; // Maximum Retail Price (same for all stores)

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.mrp,
  });
}

class StoreProductModel {
  final String productId;
  final String productName;
  final String storeName;
  final double mrp; // Original price (crossed out)
  final double price; // Actual selling price (varies by store)
  final String? distance;
  final String? location;
  final String? deliveryDate;
  final bool isOnline;
  final String storeId;
  final double? rating;
  final int? reviewCount;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? travelTime;
  final String? openingTime;

  StoreProductModel({
    required this.productId,
    required this.productName,
    required this.storeName,
    required this.mrp,
    required this.price,
    this.distance,
    this.location,
    this.deliveryDate,
    required this.isOnline,
    required this.storeId,
    this.rating,
    this.reviewCount,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.travelTime,
    this.openingTime,
  });

  // Calculate discount percentage
  double get discountPercentage {
    return ((mrp - price) / mrp * 100);
  }

  // Calculate savings
  double get savings {
    return mrp - price;
  }
}
