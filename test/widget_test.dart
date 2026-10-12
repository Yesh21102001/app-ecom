import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/app.dart';
import 'package:flutter_application/data/product_repository.dart';
import 'package:flutter_application/data/shopify_storefront_repository.dart';
import 'package:flutter_application/models/product.dart';
import 'package:flutter_application/screens/main_shell.dart';
import "package:flutter_application/state/shop_state.dart";
import "package:flutter_application/widgets/product_card.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await shop.loadCatalog(const _TestStore());
  });

  testWidgets('store onboarding completes into the product shop', (
    tester,
  ) async {
    await tester.pumpWidget(const App(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.textContaining('perfect plant'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Search Products'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('onboarding_complete'), isTrue);
  });

  testWidgets('completed onboarding opens the product shop', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await tester.pumpWidget(const App(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('Search Products'), findsOneWidget);
    expect(find.text('Found 2 results'), findsOneWidget);
    expect(find.textContaining('Today’s care'), findsNothing);
  });

  testWidgets('shop navigation displays Shopify collections and products', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await tester.pumpWidget(const App(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Categories').last);
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Indoor Plants'), findsOneWidget);

    await tester.tap(find.text('Indoor Plants'));
    await tester.pumpAndSettle();
    expect(find.text('Lucky Jade Plant'), findsOneWidget);
  });

  testWidgets('bottom navigation opens wishlist, cart and profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await tester.pumpWidget(const App(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Your wishlist is empty'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
  });

  testWidgets("product grid cards do not overflow with long names", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final long = Product(
      id: "long",
      name: "A very long product name that wraps onto two lines in the card",
      description: "",
      image: "",
      price: 123456,
      compareAtPrice: 234567,
      collectionIds: const [],
      variants: const [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              ProductSliverGrid(products: [long, long, long, long]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group("ShopState cart", () {
    late ShopState state;

    setUp(() async {
      state = ShopState();
      await state.loadCatalog(const _TestStore());
    });

    test('same variant merges into one line', () {
      final saree = state.products.first;
      state.addToBag(saree, saree.variants.first);
      state.addToBag(saree, saree.variants.first);

      expect(state.bag.length, 1);
      expect(state.bagCount, 2);
      expect(state.bagTotal, saree.variants.first.price * 2);
    });

    test('different variants stay as separate lines', () {
      final dress = state.products[1];
      state.addToBag(dress, dress.variants[0]);
      state.addToBag(dress, dress.variants[1]);

      expect(state.bag.length, 2);
      expect(state.bagCount, 2);
    });

    test('quantity below one removes the line', () {
      final dress = state.products[1];
      state.addToBag(dress, dress.variants[0]);
      state.changeQuantity(state.bag.first, -1);

      expect(state.bag, isEmpty);
      expect(state.bagTotal, 0);
    });

    test('mrp total uses compare-at price only where the store has one', () {
      final saree = state.products.first; // has compare-at price 4999
      final earrings = state.products.last; // no compare-at price
      state.addToBag(saree, saree.variants.first);
      state.addToBag(earrings, earrings.variants.first);

      expect(state.bagMrpTotal, 4999 + earrings.variants.first.price);
      expect(state.bagTotal, 2999 + earrings.variants.first.price);
    });

    test('wishlist toggles on and off', () {
      final id = state.products.first.id;
      state.toggleWishlist(id);
      expect(state.isWishlisted(id), isTrue);
      state.toggleWishlist(id);
      expect(state.isWishlisted(id), isFalse);
    });
  });

  group('ShopifyStorefrontRepository', () {
    test('maps collections, products, variants and prices', () async {
      final client = MockClient((request) async {
        expect(
          request.headers['X-Shopify-Storefront-Access-Token'],
          'test-token',
        );
        return http.Response(jsonEncode(_fixtureResponse), 200);
      });
      final repository = ShopifyStorefrontRepository(
        storeDomain: 'example.myshopify.com',
        storefrontToken: 'test-token',
        apiVersion: '2026-04',
        client: client,
      );

      final catalog = await repository.fetchCatalog();

      expect(catalog.collections.single.title, 'New Arrivals');
      final plant = catalog.products.single;
      expect(plant.name, 'Indoor plant');
      expect(plant.price, 999);
      expect(plant.compareAtPrice, isNull);
      expect(plant.collectionIds, ['gid://shopify/Collection/1']);
      expect(plant.optionNames, ['Color']);
      expect(plant.variants.map((v) => v.title), ['Green', 'Beige']);
      expect(plant.variants.first.options, {'Color': 'Green'});
    });

    test('throws when the store returns errors', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'errors': [
              {'message': 'Access denied'},
            ],
          }),
          200,
        ),
      );
      final repository = ShopifyStorefrontRepository(
        storeDomain: 'example.myshopify.com',
        storefrontToken: 'bad',
        apiVersion: '2026-04',
        client: client,
      );

      expect(repository.fetchCatalog(), throwsA(isA<StorefrontException>()));
    });
  });
}

/// Test-only store with two products and one collection.
class _TestStore implements ProductRepository {
  const _TestStore();

  @override
  Future<StoreCatalog> fetchCatalog() async => const StoreCatalog(
    collections: [ShopCollection(id: 'c1', title: 'Indoor Plants', imageUrl: '')],
    products: [
      Product(
        id: 't1',
        name: 'Lucky Jade Plant',
        description: '',
        image: '',
        price: 2999,
        compareAtPrice: 4999,
        collectionIds: ['c1'],
        variants: [
          ProductVariant(
            id: 'v1',
            title: 'Red',
            price: 2999,
            available: true,
            options: {'Color': 'Red'},
          ),
        ],
      ),
      Product(
        id: 't2',
        name: 'Monstera Deliciosa',
        description: '',
        image: '',
        price: 1999,
        compareAtPrice: null,
        collectionIds: ['c1'],
        variants: [
          ProductVariant(
            id: 'v2',
            title: 'S',
            price: 1999,
            available: true,
            options: {'Size': 'S'},
          ),
          ProductVariant(
            id: 'v3',
            title: 'M',
            price: 1999,
            available: true,
            options: {'Size': 'M'},
          ),
        ],
      ),
    ],
  );
}

/// A trimmed Storefront response shaped like the real API.
final _fixtureResponse = {
  'data': {
    'collections': {
      'nodes': [
        {
          'id': 'gid://shopify/Collection/1',
          'title': 'New Arrivals',
          'image': {'url': 'https://cdn.example.com/c.png'},
        },
      ],
    },
    'products': {
      'nodes': [
        {
          'id': 'gid://shopify/Product/9',
          'title': 'Indoor plant',
          'description': 'A small plant.',
          'featuredImage': {'url': 'https://cdn.example.com/p.png'},
          'priceRange': {
            'minVariantPrice': {'amount': '999.0'},
          },
          'compareAtPriceRange': {
            'minVariantPrice': {'amount': '0.0'},
          },
          'collections': {
            'nodes': [
              {'id': 'gid://shopify/Collection/1'},
            ],
          },
          'variants': {
            'nodes': [
              {
                'id': 'gid://shopify/ProductVariant/1',
                'title': 'Green',
                'availableForSale': true,
                'price': {'amount': '999.0'},
                'selectedOptions': [
                  {'name': 'Color', 'value': 'Green'},
                ],
              },
              {
                'id': 'gid://shopify/ProductVariant/2',
                'title': 'Beige',
                'availableForSale': true,
                'price': {'amount': '999.0'},
                'selectedOptions': [
                  {'name': 'Color', 'value': 'Beige'},
                ],
              },
            ],
          },
        },
      ],
    },
  },
};
