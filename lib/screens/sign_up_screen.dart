import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';
import '../widgets/labeled_field.dart';
import 'login_screen.dart';

/// Create-account page from the "fashion." kit. Like sign in, this is a
/// placeholder until a real account service is connected.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _agreed = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (!_agreed) {
      setState(() => _error = 'Accept the Terms & Conditions to continue');
      return;
    }
    shop.login(email);
    Navigator.of(context).pop(true);
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
              'Create Account',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill your information below or register\nwith your social account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: textGrey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),
            LabeledField(
              label: 'Name',
              hint: 'John Doe',
              controller: _nameController,
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Email',
              hint: 'example@gmail.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
                Text(
                  'Agree with ',
                  style: GoogleFonts.inter(color: textDark, fontSize: 13),
                ),
                Text(
                  'Terms & Condition',
                  style: GoogleFonts.inter(
                    color: brandPrimary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    _error!,
                    style: GoogleFonts.inter(color: errorRed, fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _signUp, child: const Text('Sign Up')),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or sign up with',
                    style: GoogleFonts.inter(color: textGrey, fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            const SocialLoginRow(),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(color: textDark, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Sign In',
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
