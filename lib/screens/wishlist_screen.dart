import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/shop_app_bar.dart';

/// Wishlist tab with collection chips over a product grid.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  /// Null means all saved products. Otherwise a Shopify collection id.
  String? _collectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShopAppBar(
        title: Text(
          'My Wishlist',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final saved = shop.wishlist;
          if (saved.isEmpty) return const _EmptyWishlist();

          final visible = _collectionId == null
              ? saved
              : saved
                  .where((p) => p.collectionIds.contains(_collectionId))
                  .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _chip('All', null),
                      for (final c in shop.collections) _chip(c.title, c.id),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ProductSliverGrid(products: visible),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, String? collectionId) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: OptionChip(
        label: label,
        selected: _collectionId == collectionId,
        onTap: () => setState(() => _collectionId = collectionId),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 72, color: textGrey),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the heart on any product to save it here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
