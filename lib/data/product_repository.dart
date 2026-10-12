import '../models/product.dart';

/// Everything the shop screens need from the store in one load.
class StoreCatalog {
  const StoreCatalog({required this.products, required this.collections});

  final List<Product> products;
  final List<ShopCollection> collections;

  static const empty = StoreCatalog(products: [], collections: []);
}

/// The app reads the store only through this interface.
abstract class ProductRepository {
  Future<StoreCatalog> fetchCatalog();
}

/// Used when no store is configured. Returns an empty catalog, so the app
/// shows empty states instead of made-up items.
class UnconnectedProductRepository implements ProductRepository {
  const UnconnectedProductRepository();

  @override
  Future<StoreCatalog> fetchCatalog() async => StoreCatalog.empty;
}
