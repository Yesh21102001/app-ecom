import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/labeled_field.dart';
import 'sign_up_screen.dart';

/// Sign-in page from the "fashion." kit.
///
/// The check is a placeholder: any email with "@" and a password of 6+
/// characters signs in. Connect Shopify's Customer Account API before release.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    shop.login(email);
    Navigator.of(context).pop(true);
  }

  void _openSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackCircleButton(),
        leadingWidth: 60,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Text(
              'Sign In',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hi! Welcome back, you've been missed",
              style: GoogleFonts.inter(color: textGrey, fontSize: 14),
            ),
            const SizedBox(height: 36),
            LabeledField(
              label: 'Email',
              hint: 'example@gmail.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'Password',
              hint: '••••••••••••••••',
              controller: _passwordController,
              obscure: _hidePassword,
              suffix: IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: textGrey,
                ),
                onPressed: () =>
                    setState(() => _hidePassword = !_hidePassword),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    color: brandPrimary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(color: errorRed, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            FilledButton(onPressed: _signIn, child: const Text('Sign In')),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or sign in with',
                    style: GoogleFonts.inter(color: textGrey, fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            const SocialLoginRow(),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: GoogleFonts.inter(color: textDark, fontSize: 14),
                ),
                TextButton(
                  onPressed: _openSignUp,
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.inter(
                      color: brandPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Three round social buttons. Logos are text stand-ins until real logo
/// assets are added. The buttons do nothing yet.
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    const providers = ['', 'G', 'f'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final label in providers)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: surfaceGrey),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
