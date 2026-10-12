import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'product_repository.dart';

class StorefrontException implements Exception {
  StorefrontException(this.message);

  final String message;

  @override
  String toString() => 'StorefrontException: $message';
}

/// Reads collections and products from the Shopify Storefront GraphQL API.
///
/// Only the public Storefront token is used here. Never add an Admin token.
class ShopifyStorefrontRepository implements ProductRepository {
  ShopifyStorefrontRepository({
    required this.storeDomain,
    required this.storefrontToken,
    required this.apiVersion,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String storeDomain;
  final String storefrontToken;
  final String apiVersion;
  final http.Client _client;

  Uri get _endpoint =>
      Uri.https(storeDomain, '/api/$apiVersion/graphql.json');

  static const _catalogQuery = r'''
query Catalog {
  collections(first: 50) {
    nodes { id title image { url } }
  }
  products(first: 100) {
    nodes {
      id
      title
      description
      featuredImage { url }
      priceRange { minVariantPrice { amount } }
      compareAtPriceRange { minVariantPrice { amount } }
      collections(first: 20) { nodes { id } }
      variants(first: 100) {
        nodes {
          id
          title
          availableForSale
          price { amount }
          selectedOptions { name value }
        }
      }
    }
  }
}
''';

  @override
  Future<StoreCatalog> fetchCatalog() async {
    final response = await _client.post(
      _endpoint,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': storefrontToken,
      },
      body: jsonEncode({'query': _catalogQuery}),
    );

    if (response.statusCode != 200) {
      throw StorefrontException(
        'Store returned status ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first as Map<String, dynamic>;
      throw StorefrontException(first['message'] as String? ?? 'Unknown error');
    }

    final data = body['data'] as Map<String, dynamic>;
    return StoreCatalog(
      collections: _parseCollections(data['collections']),
      products: _parseProducts(data['products']),
    );
  }

  List<Map<String, dynamic>> _nodes(Object? connection) {
    final map = connection as Map<String, dynamic>;
    return (map['nodes'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  List<ShopCollection> _parseCollections(Object? connection) {
    return [
      for (final node in _nodes(connection))
        ShopCollection(
          id: node['id'] as String,
          title: node['title'] as String,
          imageUrl: _imageUrl(node['image']),
        ),
    ];
  }

  List<Product> _parseProducts(Object? connection) {
    return [
      for (final node in _nodes(connection))
        Product(
          id: node['id'] as String,
          name: node['title'] as String,
          description: (node['description'] as String?) ?? '',
          image: _imageUrl(node['featuredImage']),
          price: _amount(
            (node['priceRange'] as Map<String, dynamic>)['minVariantPrice'],
          ),
          compareAtPrice: _optionalAmount(
            (node['compareAtPriceRange'] as Map<String, dynamic>)['minVariantPrice'],
          ),
          variants: _parseVariants(node['variants']),
          collectionIds: [
            for (final c in _nodes(node['collections'])) c['id'] as String,
          ],
        ),
    ];
  }

  List<ProductVariant> _parseVariants(Object? connection) {
    return [
      for (final node in _nodes(connection))
        ProductVariant(
          id: node['id'] as String,
          title: node['title'] as String,
          price: _amount(node['price']),
          available: node['availableForSale'] as bool? ?? false,
          options: {
            for (final option
                in (node['selectedOptions'] as List<dynamic>)
                    .cast<Map<String, dynamic>>())
              option['name'] as String: option['value'] as String,
          },
        ),
    ];
  }

  String _imageUrl(Object? image) {
    if (image is! Map<String, dynamic>) return '';
    return image['url'] as String? ?? '';
  }

  /// Storefront money is a string like "999.0". Shown as whole rupees.
  int _amount(Object? money) {
    final map = money as Map<String, dynamic>;
    return double.parse(map['amount'] as String).round();
  }

  /// Compare-at prices come back as "0.0" when unset. Treat zero as no price.
  int? _optionalAmount(Object? money) {
    final value = _amount(money);
    return value == 0 ? null : value;
  }
}
