/// One purchasable option of a product, such as "Green" or "Large".
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.available,
    required this.options,
  });

  /// Shopify variant id (gid://shopify/ProductVariant/...).
  final String id;
  final String title;

  /// Selling price in rupees.
  final int price;
  final bool available;

  /// Option name to value, e.g. {'Color': 'Green'}.
  final Map<String, String> options;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.compareAtPrice,
    required this.variants,
    required this.collectionIds,
  });

  final String id;
  final String name;
  final String description;

  /// Empty when the store has no image for the product.
  final String image;

  /// Lowest variant price in rupees.
  final int price;

  /// Original price in rupees. Null when the store has no compare-at price.
  final int? compareAtPrice;
  final List<ProductVariant> variants;

  /// Shopify collection ids this product belongs to.
  final List<String> collectionIds;

  /// Option names used by the variants, e.g. ['Color'] or ['Size', 'Color'].
  List<String> get optionNames {
    final names = <String>[];
    for (final variant in variants) {
      for (final name in variant.options.keys) {
        if (!names.contains(name)) names.add(name);
      }
    }
    return names;
  }

  int? get discountPercent {
    final mrp = compareAtPrice;
    if (mrp == null || mrp <= price) return null;
    return ((mrp - price) * 100 / mrp).round();
  }
}

/// A Shopify collection, used as a category.
class ShopCollection {
  const ShopCollection({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;

  /// Empty when the collection has no image.
  final String imageUrl;
}

/// Formats rupees with Indian digit grouping: 1234567 -> ₹12,34,567.
String formatRupees(int amount) {
  final digits = amount.toString();
  if (digits.length <= 3) return '₹$digits';

  final lastThree = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);

  return '₹${groups.join(',')},$lastThree';
}
