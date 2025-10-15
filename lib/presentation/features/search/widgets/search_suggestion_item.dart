import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';

class SearchSuggestionItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final ThemeData theme;

  const SearchSuggestionItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(product.category),
            color: theme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.tertiary,
          ),
        ),
        subtitle: Text(
          product.category,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.tertiary.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.tertiary.withOpacity(0.4),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'smartphones':
        return Icons.smartphone;
      case 'electronics':
        return Icons.tv;
      case 'laptops':
        return Icons.laptop;
      default:
        return Icons.shopping_bag;
    }
  }
}
