import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Round outlined back button used at the top left of most screens.
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: InkResponse(
          onTap: () => Navigator.of(context).maybePop(),
          radius: 28,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: surfaceGrey),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: textDark),
          ),
        ),
      ),
    );
  }
}

/// Small white circle with an icon, used for the heart on product cards.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onTap,
    this.color = textDark,
    this.size = 34,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size * 0.55, color: color),
      ),
    );
  }
}

/// Rounded pill chip: brown when selected, light grey when not.
class OptionChip extends StatelessWidget {
  const OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.minWidth = 0,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? brandPrimary : surfaceGrey,
          borderRadius: BorderRadius.circular(24),
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
    );
  }
}

/// Square size box (S, M, L...). Selected box is filled brown.
class SizeBox extends StatelessWidget {
  const SizeBox({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
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
    );
  }
}

/// Stand-in for a product or banner photo. The fashion kit's photos are not
/// in this project yet, so this shows a warm block with an icon instead.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    this.icon = Icons.image_outlined,
    this.color = surfaceTint,
    this.radius = 12,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: textGrey.withValues(alpha: 0.6), size: 34),
    );
  }
}

/// Logo used on the splash/onboarding: a brown round "f" and "fashion." text.
class FashionLogo extends StatelessWidget {
  const FashionLogo({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: brandPrimary,
            shape: BoxShape.circle,
          ),
          child: Text(
            'f',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: size * 0.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            text: 'fashion',
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: brandPrimary),
              ),
            ],
          ),
          style: GoogleFonts.playfairDisplay(
            color: textDark,
            fontSize: size * 0.7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
