import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selected;
  bool _expanded = false;

  ProductVariant? get _firstAvailable {
    for (final variant in widget.product.variants) {
      if (variant.available) return variant;
    }
    return null;
  }

  void _addToCart() {
    final variant = _selected;
    final messenger = ScaffoldMessenger.of(context);
    if (variant == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Select an option first')),
        );
      return;
    }
    shop.addToBag(widget.product, variant);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final selected = _selected;
    final shownPrice = selected?.price ?? product.price;
    // Shopify gives single-variant products an option named "Title".
    final hasOptions = product.optionNames.any((name) => name != 'Title');
    final optionLabel = product.optionNames.join(' / ');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackCircleButton(),
        leadingWidth: 60,
        title: Text(
          'Product Details',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          ListenableBuilder(
            listenable: shop,
            builder: (context, _) {
              final saved = shop.isWishlisted(product.id);
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Center(
                  child: InkResponse(
                    onTap: () => shop.toggleWishlist(product.id),
                    radius: 26,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceGrey),
                      ),
                      child: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? errorRed : textDark,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Container(
            height: 360,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cardRadius),
              child: product.image.isEmpty
                  ? const PhotoPlaceholder(radius: 0)
                  : Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const PhotoPlaceholder(radius: 0),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      formatRupees(shownPrice),
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (product.compareAtPrice != null)
                      Text(
                        formatRupees(product.compareAtPrice!),
                        style: GoogleFonts.inter(
                          color: textGrey,
                          fontSize: 15,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (product.discountPercent != null)
                      Text(
                        '${product.discountPercent}% off',
                        style: GoogleFonts.inter(
                          color: errorRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Product Details',
                    style: GoogleFonts.inter(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: textGrey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : 'Read more',
                      style: GoogleFonts.inter(
                        color: brandPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                if (hasOptions) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Select $optionLabel',
                    style: GoogleFonts.inter(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final variant in product.variants)
                        _VariantBox(
                          label: variant.title,
                          selected: selected?.id == variant.id,
                          enabled: variant.available,
                          onTap: () => setState(() => _selected = variant),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRupees(shownPrice),
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: FilledButton.icon(
                  onPressed: (_selected ?? _firstAvailable) == null
                      ? null
                      : _addToCart,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Option box for one variant. Unavailable variants are shown but can't be
/// picked.
class _VariantBox extends StatelessWidget {
  const _VariantBox({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? brandPrimary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? brandPrimary : surfaceGrey),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? Colors.white : textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
