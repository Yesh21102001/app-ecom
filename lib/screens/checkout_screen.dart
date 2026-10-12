import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';

/// Checkout: delivery address, order list and total.
///
/// Placing the order needs the Shopify checkout, which is not connected yet.
/// The button says so instead of pretending to place an order.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  void _notConnected(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackCircleButton(),
        leadingWidth: 60,
        title: Text(
          'Checkout',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              const _SectionTitle('Shipping Address'),
              const SizedBox(height: 12),
              _AddressCard(
                onAdd: () => _notConnected(
                  context,
                  'Address book is not connected yet',
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Order List'),
              const SizedBox(height: 12),
              for (final item in shop.bag)
                _OrderRow(
                  product: item.product,
                  size: item.variant.title,
                  unitPrice: item.variant.price,
                  quantity: item.quantity,
                ),
              const Divider(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    formatRupees(shop.bagTotal),
                    style: GoogleFonts.inter(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: shop.bag.isEmpty
                ? null
                : () => _notConnected(
                      context,
                      'Checkout is not connected to the store yet',
                    ),
            child: const Text('Place Order'),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: surfaceGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No address saved yet',
                style: GoogleFonts.inter(color: textGrey, fontSize: 14),
              ),
            ),
            Text(
              'ADD',
              style: GoogleFonts.inter(
                color: brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.product,
    required this.size,
    required this.unitPrice,
    required this.quantity,
  });

  final Product product;
  final String size;
  final int unitPrice;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 80,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const PhotoPlaceholder(radius: 0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$size  ·  Qty : $quantity',
                  style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatRupees(unitPrice * quantity),
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
