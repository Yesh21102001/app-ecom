import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

/// One line in the cart: a product variant and how many of it.
class BagItem {
  BagItem({required this.product, required this.variant, this.quantity = 1});

  final Product product;
  final ProductVariant variant;
  int quantity;
}

/// Catalog, wishlist and cart kept in memory.
///
/// The cart should move to a Shopify cart (cartCreate / cartLinesAdd) before
/// checkout. Each line already stores the variant id Shopify needs.
class ShopState extends ChangeNotifier {
  List<Product> _products = const [];
  List<ShopCollection> _collections = const [];
  String? _loadError;
  bool _loading = false;

  final Set<String> _wishlistIds = {};
  final List<BagItem> _bag = [];
  String? _account;

  List<Product> get products => _products;
  List<ShopCollection> get collections => _collections;
  String? get loadError => _loadError;
  bool get isLoading => _loading;

  /// True once the catalog has been requested, even if it came back empty.
  bool get hasStore => _products.isNotEmpty || _collections.isNotEmpty;

  bool get isLoggedIn => _account != null;
  String? get account => _account;

  void login(String account) {
    _account = account;
    notifyListeners();
  }

  void logout() {
    _account = null;
    notifyListeners();
  }

  Future<void> loadCatalog(ProductRepository repository) async {
    _loading = true;
    _loadError = null;
    notifyListeners();
    try {
      final catalog = await repository.fetchCatalog();
      _products = catalog.products;
      _collections = catalog.collections;
    } catch (error) {
      _loadError = 'Could not load the store. Check the connection and config.';
      debugPrint('Catalog load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Called when no store is configured, so the screen can explain why it is empty.
  void reportNotConnected() {
    _loadError =
        "Store is not connected. Run the app with --dart-define-from-file=config/shopify.local.json";
    notifyListeners();
  }

  List<Product> get wishlist =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  void toggleWishlist(String productId) {
    if (!_wishlistIds.remove(productId)) _wishlistIds.add(productId);
    notifyListeners();
  }

  List<BagItem> get bag => List.unmodifiable(_bag);

  int get bagCount => _bag.fold(0, (sum, item) => sum + item.quantity);

  /// Total at selling prices.
  int get bagTotal =>
      _bag.fold(0, (sum, item) => sum + item.variant.price * item.quantity);

  /// Total at original prices. Items without a compare-at price count at
  /// their selling price, so they add no discount.
  int get bagMrpTotal => _bag.fold(
        0,
        (sum, item) =>
            sum +
            (item.product.compareAtPrice ?? item.variant.price) * item.quantity,
      );

  /// Adds one unit. The same variant is merged into one line.
  void addToBag(Product product, ProductVariant variant) {
    for (final item in _bag) {
      if (item.variant.id == variant.id) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _bag.add(BagItem(product: product, variant: variant));
    notifyListeners();
  }

  void changeQuantity(BagItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) _bag.remove(item);
    notifyListeners();
  }

  void clearBag() {
    _bag.clear();
    notifyListeners();
  }
}

/// App-wide shop state. Shared by every screen.
final shop = ShopState();
