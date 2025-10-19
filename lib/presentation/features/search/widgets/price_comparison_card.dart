import 'package:flutter/material.dart';
import '../../../../data/data_sources/local/search_data.dart';

class PriceComparisonCard extends StatelessWidget {
  final PriceComparisonItem item;
  final ThemeData theme;
  final bool isFirst;
  final bool isCheapest;

  const PriceComparisonCard({
    super.key,
    required this.item,
    required this.theme,
    this.isFirst = false,
    this.isCheapest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(
        left: isFirst ? 0 : 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCheapest 
              ? Colors.green 
              : theme.primaryColor.withOpacity(0.2),
          width: isCheapest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCheapest
                ? Colors.green.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.isOnline
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.isOnline ? Icons.language : Icons.store,
                            size: 12,
                            color: item.isOnline ? Colors.blue : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.isOnline ? Colors.blue : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  item.storeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.isOnline ? Icons.local_shipping : Icons.location_on,
                      size: 14,
                      color: theme.colorScheme.tertiary.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.isOnline
                            ? 'Delivery: ${item.deliveryTime}'
                            : item.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.tertiary.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCheapest ? Colors.green : theme.primaryColor,
                      ),
                    ),
                    Text(
                      item.price.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isCheapest ? Colors.green : theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (isCheapest)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF43e97b)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Cheapest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
