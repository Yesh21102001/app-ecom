import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/shop_app_bar.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

/// Profile tab: avatar, name, then the menu list from the kit.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShopAppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final loggedIn = shop.isLoggedIn;
          final account = shop.account;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: surfaceTint,
                      child: Icon(Icons.person, color: brandPrimary, size: 44),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loggedIn ? account! : 'Guest',
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OptionChip(
                      label: loggedIn ? 'Log Out' : 'Sign In',
                      selected: false,
                      onTap: () => loggedIn
                          ? shop.logout()
                          : _open(context, const LoginScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _MenuTile(
                icon: Icons.person_outline,
                label: 'Your profile',
                onTap: () => _comingSoon(context, 'Your profile'),
              ),
              _MenuTile(
                icon: Icons.credit_card_outlined,
                label: 'Payment Methods',
                onTap: () => _comingSoon(context, 'Payment Methods'),
              ),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                label: 'My Orders',
                onTap: () => _open(context, const OrdersScreen()),
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => _comingSoon(context, 'Settings'),
              ),
              _MenuTile(
                icon: Icons.help_outline,
                label: 'Help Center',
                onTap: () => _comingSoon(context, 'Help Center'),
              ),
              _MenuTile(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () => _comingSoon(context, 'Privacy Policy'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textDark, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: textDark),
          ],
        ),
      ),
    );
  }
}
