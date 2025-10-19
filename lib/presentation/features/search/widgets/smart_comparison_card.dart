import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/product_model.dart';
import '../../../../core/utils/number_formatter.dart';

class SmartComparisonCard extends StatelessWidget {
  final StoreProductModel store;
  final ThemeData theme;
  final bool isFirst;
  final bool isBestChoice;
  final String reason;

  const SmartComparisonCard({
    super.key,
    required this.store,
    required this.theme,
    this.isFirst = false,
    this.isBestChoice = false,
    this.reason = '',
  });

  Future<void> _openDirections() async {
    if (store.latitude != null && store.longitude != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (store.phoneNumber != null) {
      final url = 'tel:${store.phoneNumber}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void _showReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  color: theme.primaryColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Why This Store?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reason.isEmpty 
                    ? 'This store offers great value based on price, location, and customer reviews.'
                    : reason,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.tertiary.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: EdgeInsets.only(left: isFirst ? 0 : 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBestChoice ? Colors.green.shade400 : theme.primaryColor.withOpacity(0.2),
          width: isBestChoice ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isBestChoice
                ? Colors.green.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isBestChoice ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: store.isOnline ? Colors.blue.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                store.isOnline ? Icons.language : Icons.store,
                                size: 14,
                                color: store.isOnline ? Colors.blue.shade700 : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                store.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: store.isOnline ? Colors.blue.shade700 : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (store.rating != null) ...[
                          Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            store.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            ' (${store.reviewCount ?? 25})',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.tertiary.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      store.storeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location/Delivery
                      Row(
                        children: [
                          Icon(
                            store.isOnline ? Icons.local_shipping : Icons.location_on,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              store.isOnline
                                  ? 'Delivery: ${store.deliveryDate ?? "N/A"}'
                                  : store.location ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.tertiary.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      if (!store.isOnline && store.distance != null)
                        Row(
                          children: [
                            Icon(Icons.directions_walk, size: 16, color: theme.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              '${store.distance} away',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.tertiary.withOpacity(0.8),
                              ),
                            ),
                            if (store.travelTime != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${store.travelTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      
                      if (!store.isOnline && store.openingTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                store.openingTime!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.tertiary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // MRP + Actual Price + Discount (INDIAN FORMAT)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MRP (Strikethrough) - INDIAN FORMAT
                          Row(
                            children: [
                              Text(
                                'MRP: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                NumberFormatter.formatIndianPrice(store.mrp),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.red,
                                  decorationThickness: 2,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Actual Price + Discount + Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Price - INDIAN FORMAT
                              Expanded(
                                child: Text(
                                  NumberFormatter.formatIndianPrice(store.price),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isBestChoice ? Colors.green.shade700 : theme.primaryColor,
                                    height: 1,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Text(
                                  '${store.discountPercentage.toStringAsFixed(0)}% OFF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 4),
                              
                              if (reason.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _showReasonDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Savings - INDIAN FORMAT
                          Text(
                            'You save ${NumberFormatter.formatIndianPrice(store.savings)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Buttons
                      Row(
                        children: [
                          if (!store.isOnline) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _openDirections,
                                icon: const Icon(Icons.directions, size: 16),
                                label: const Text('Directions', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: _makePhoneCall,
                                icon: Icon(Icons.phone, color: theme.primaryColor),
                                padding: const EdgeInsets.all(10),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ] else
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.shopping_cart, size: 16),
                                label: const Text('Visit Store', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Best Choice Badge
          if (isBestChoice)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.green.shade700],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Best Choice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
