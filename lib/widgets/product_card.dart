import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import 'design_widgets.dart';

/// Two-column product grid. Tapping a card opens the product detail screen.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({required this.products, super.key});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(
            product: products[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: products[index]),
              ),
            ),
          ),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 14,
          childAspectRatio: 0.7,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: _ProductImage(url: product.image),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _WishlistButton(productId: product.id),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                formatRupees(product.price),
                style: GoogleFonts.inter(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (product.compareAtPrice != null)
                Text(
                  formatRupees(product.compareAtPrice!),
                  style: GoogleFonts.inter(
                    color: textGrey,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (discount != null)
                Text(
                  '$discount% off',
                  style: GoogleFonts.inter(
                    color: errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const PhotoPlaceholder(radius: 0);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const PhotoPlaceholder(radius: 0),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shop,
      builder: (context, _) {
        final saved = shop.isWishlisted(productId);
        return CircleIconButton(
          icon: saved ? Icons.favorite : Icons.favorite_border,
          color: saved ? errorRed : textDark,
          onTap: () => shop.toggleWishlist(productId),
        );
      },
    );
  }
}
