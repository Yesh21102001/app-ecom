import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import 'product_list_screen.dart';

/// Categories tab: every collection in the store, as tiles.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          'Categories',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final collections = shop.collections;
          if (collections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: shop.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        shop.loadError ?? 'No categories in the store yet.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: textGrey, fontSize: 14),
                      ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: collections.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) =>
                _CollectionTile(collection: collections[index]),
          );
        },
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection});

  final ShopCollection collection;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(cardRadius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListScreen(
            title: collection.title,
            collectionId: collection.id,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            collection.imageUrl.isEmpty
                ? const PhotoPlaceholder(radius: 0)
                : Image.network(
                    collection.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const PhotoPlaceholder(radius: 0),
                  ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white.withValues(alpha: 0.9),
                child: Text(
                  collection.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
