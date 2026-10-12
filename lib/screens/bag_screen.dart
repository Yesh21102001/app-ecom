import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/shop_app_bar.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

/// "My Cart" tab. The kit's cart: item rows with a quantity stepper, swipe to
/// remove, then a summary card and "Proceed to Checkout".
class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  Future<void> _proceed(BuildContext context) async {
    if (!shop.isLoggedIn) {
      final loggedIn = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (loggedIn != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shop,
      builder: (context, _) {
        final items = shop.bag;

        return Scaffold(
          appBar: ShopAppBar(
            title: Text(
              'Cart',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: items.isEmpty
              ? const _EmptyCart()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    for (final item in items)
                      Dismissible(
                        key: ValueKey(item.variant.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            shop.changeQuantity(item, -item.quantity),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: errorRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(cardRadius),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: errorRed,
                          ),
                        ),
                        child: _CartRow(item: item),
                      ),
                    const SizedBox(height: 8),
                    _Summary(
                      subtotal: shop.bagMrpTotal,
                      discount: shop.bagMrpTotal - shop.bagTotal,
                      total: shop.bagTotal,
                    ),
                  ],
                ),
          bottomNavigationBar: items.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: FilledButton(
                      onPressed: () => _proceed(context),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 72, color: textGrey),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add items you like to it now.',
            style: GoogleFonts.inter(color: textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final BagItem item;

  @override
  Widget build(BuildContext context) {
    final Product product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: SizedBox(
              width: 88,
              height: 110,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const PhotoPlaceholder(radius: 0),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.variant.title,
                  style: GoogleFonts.inter(color: textGrey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupees(item.variant.price),
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _Stepper(
            quantity: item.quantity,
            onMinus: () => shop.changeQuantity(item, -1),
            onPlus: () => shop.changeQuantity(item, 1),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.add, filled: true, onTap: onPlus),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '$quantity',
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _StepButton(icon: Icons.remove, filled: false, onTap: onMinus),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: filled ? brandPrimary : surfaceGrey),
        ),
        child: Icon(icon, size: 16, color: filled ? Colors.white : textDark),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final int subtotal;
  final int discount;
  final int total;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false, Color? color}) {
      final style = GoogleFonts.inter(
        color: color ?? textDark,
        fontSize: bold ? 16 : 14,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(value, style: style),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: surfaceGrey),
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                child: Text(
                  'Promo Code',
                  style: GoogleFonts.inter(color: textGrey, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(90, 52)),
                onPressed: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Promo codes are not connected yet'),
                    ),
                  ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        row('Sub-Total', formatRupees(subtotal)),
        row('Delivery Fee', 'Calculated at checkout'),
        if (discount > 0)
          row('Discount', '-${formatRupees(discount)}', color: errorRed),
        const Divider(height: 24),
        row('Total Cost', formatRupees(total), bold: true),
      ],
    );
  }
}
