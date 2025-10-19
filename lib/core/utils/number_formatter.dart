class NumberFormatter {
  /// Formats number in Indian numbering system
  /// Example: 1234567 → 12,34,567
  /// Example: 129999 → 1,29,999
  static String formatIndianCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    
    if (str.length <= 3) {
      return str;
    }
    
    // Split into parts: last 3 digits and remaining
    final lastThree = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);
    
    // Add commas every 2 digits in remaining part (from right to left)
    String formatted = '';
    int count = 0;
    
    for (int i = remaining.length - 1; i >= 0; i--) {
      if (count == 2) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = remaining[i] + formatted;
      count++;
    }
    
    return '$formatted,$lastThree';
  }
  
  /// Formats with rupee symbol
  /// Example: 1234567 → ₹12,34,567
  static String formatIndianPrice(double amount) {
    return '₹${formatIndianCurrency(amount)}';
  }
  
  /// Formats decimal values (for display purposes)
  /// Example: 1234567.50 → ₹12,34,567.50
  static String formatIndianPriceWithDecimal(double amount) {
    final intPart = amount.floor();
    final decimalPart = (amount - intPart).toStringAsFixed(2).substring(2);
    
    if (decimalPart == '00') {
      return formatIndianPrice(intPart.toDouble());
    }
    
    return '${formatIndianPrice(intPart.toDouble())}.$decimalPart';
  }
}
