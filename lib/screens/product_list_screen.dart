import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/product_card.dart';

enum SortOption {
  recommended('Recommended'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low');

  const SortOption(this.label);

  final String label;
}

/// Products from one collection, or products matching a search query.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    required this.title,
    this.collectionId,
    this.query,
    super.key,
  });

  final String title;
  final String? collectionId;
  final String? query;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  SortOption _sort = SortOption.recommended;

  List<Product> _visibleProducts() {
    final query = widget.query?.trim().toLowerCase();
    final collectionId = widget.collectionId;

    final list = shop.products.where((p) {
      if (collectionId != null && !p.collectionIds.contains(collectionId)) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        return p.name.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    switch (_sort) {
      case SortOption.recommended:
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  Future<void> _pickSort() async {
    final picked = await showModalBottomSheet<SortOption>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Sort by',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ),
            for (final option in SortOption.values)
              ListTile(
                title: Text(option.label),
                trailing: option == _sort
                    ? const Icon(Icons.check, color: brandPrimary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackCircleButton(),
        leadingWidth: 60,
        title: Text(
          widget.title,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final products = _visibleProducts();

          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No products found.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: textGrey, fontSize: 14),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text(
                          '${products.length} products',
                          style: GoogleFonts.inter(
                            color: textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    ProductSliverGrid(products: products),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: InkWell(
                  onTap: _pickSort,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: dividerColor)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Sort: ${_sort.label}',
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
