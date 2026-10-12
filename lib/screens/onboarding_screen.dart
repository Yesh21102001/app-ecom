import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/design_widgets.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.before,
    required this.highlight,
    required this.after,
    required this.icon,
    required this.description,
  });

  final String before;
  final String highlight;
  final String after;
  final IconData icon;
  final String description;
}

const _pages = [
  _OnboardingPage(
    before: 'Find your ',
    highlight: 'perfect plant',
    after: '',
    icon: Icons.eco_rounded,
    description: 'Discover plants and pots selected for a greener home.',
  ),
  _OnboardingPage(
    before: 'Browse a little ',
    highlight: 'more green',
    after: '',
    icon: Icons.grid_view_rounded,
    description: 'Explore the latest products and collections from our store.',
  ),
  _OnboardingPage(
    before: 'Bring nature ',
    highlight: 'closer to home',
    after: '',
    icon: Icons.shopping_bag_outlined,
    description: 'Save your favourites and keep your cart ready for checkout.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _back() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    setState(() => _isCompleting = true);
    try {
      await widget.onComplete();
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: isLast
                    ? null
                    : TextButton(
                        onPressed: () => _pageController.animateToPage(
                          _pages.length - 1,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) =>
                    _OnboardingPageView(page: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  _ArrowButton(
                    icon: Icons.arrow_back,
                    outlined: true,
                    onTap: _currentPage == 0 ? null : _back,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentPage ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? brandPrimary
                                : surfaceGrey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _NextButton(
                    isLast: isLast,
                    isLoading: _isCompleting,
                    onTap: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: outlined ? Colors.white : brandPrimary,
          border: outlined ? Border.all(color: surfaceGrey) : null,
        ),
        child: Icon(
          icon,
          color: outlined
              ? (onTap == null ? textGrey.withValues(alpha: 0.45) : textDark)
              : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLast,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLast;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size(116, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const StadiumBorder(),
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isLast ? 'Start' : 'Next'),
                const SizedBox(width: 8),
                Icon(
                  isLast ? Icons.check_rounded : Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.42).clamp(150.0, 320.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(180),
                    bottom: Radius.circular(24),
                  ),
                  child: PhotoPlaceholder(
                    icon: page.icon,
                    color: surfaceTint,
                    radius: 0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
              child: Text.rich(
                TextSpan(
                  text: page.before,
                  children: [
                    TextSpan(
                      text: page.highlight,
                      style: const TextStyle(color: brandPrimary),
                    ),
                    TextSpan(text: page.after),
                  ],
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: textDark,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                page.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: textGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
