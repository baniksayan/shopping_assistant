import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';

class StoreResultItem extends StatelessWidget {
  final StoreProductModel store;
  final ThemeData theme;

  const StoreResultItem({
    super.key,
    required this.store,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name and Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  store.storeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: store.isOnline
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  store.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: store.isOnline ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price
          Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 24,
                color: theme.primaryColor,
              ),
              Text(
                store.price.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Location or Delivery Info
          if (!store.isOnline) ...[
            _buildInfoRow(
              Icons.location_on,
              store.location ?? '',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.directions_walk,
              store.distance ?? '',
              theme,
            ),
          ] else ...[
            _buildInfoRow(
              Icons.local_shipping,
              'Delivery: ${store.deliveryDate}',
              theme,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Rating
          if (store.rating != null)
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  store.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${(store.rating! * 234).toInt()} reviews)',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.tertiary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 12),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to store detail or external link
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                store.isOnline ? 'Visit Store' : 'Get Directions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.tertiary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.tertiary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
