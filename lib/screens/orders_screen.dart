import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';

/// "My Orders" with Active, Completed and Cancelled tabs.
///
/// No order data exists in the app yet, so every tab shows an empty state.
/// Once Shopify orders are connected, list them here.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const BackCircleButton(),
          leadingWidth: 60,
          title: Text(
            'My Orders',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            labelColor: brandPrimary,
            unselectedLabelColor: textGrey,
            indicatorColor: brandPrimary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: dividerColor,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EmptyOrders(label: 'No active orders'),
            _EmptyOrders(label: 'No completed orders'),
            _EmptyOrders(label: 'No cancelled orders'),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: textGrey),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
