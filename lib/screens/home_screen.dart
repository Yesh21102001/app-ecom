import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/shop_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _collectionId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts() {
    final query = _query.trim().toLowerCase();
    return shop.products.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      final matchesCollection = _collectionId == null ||
          product.collectionIds.contains(_collectionId);
      return matchesQuery && matchesCollection;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShopAppBar(
        title: Text(
          'Search Products',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final products = _filteredProducts();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search plants, pots and more',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: _query.isEmpty
                            ? null
                            : () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              if (shop.collections.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _collectionChip('All', null),
                        for (final collection in shop.collections)
                          _collectionChip(collection.title, collection.id),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop.isLoading && shop.products.isEmpty
                              ? 'Loading products'
                              : 'Found ${products.length} results',
                          style: GoogleFonts.inter(
                            color: textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (products.isNotEmpty)
                ProductSliverGrid(products: products)
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CatalogState(
                    loading: shop.isLoading,
                    message: shop.loadError ??
                        (_query.isNotEmpty || _collectionId != null
                            ? 'No products match your search.'
                            : 'No products are available in the store yet.'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _collectionChip(String label, String? collectionId) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: OptionChip(
        label: label,
        selected: _collectionId == collectionId,
        onTap: () => setState(() => _collectionId = collectionId),
      ),
    );
  }
}

class _CatalogState extends StatelessWidget {
  const _CatalogState({required this.loading, required this.message});

  final bool loading;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 48,
              color: brandGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: textGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
