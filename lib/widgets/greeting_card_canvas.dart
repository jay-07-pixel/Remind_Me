import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_spacing.dart';

class GreetingCardCanvas extends StatelessWidget {
  const GreetingCardCanvas({
    super.key,
    required this.assetPath,
    required this.toName,
    required this.fromName,
    required this.message,
    this.borderRadius = AppSpacing.cardRadius,
  });

  final String assetPath;
  final String toName;
  final String fromName;
  final String message;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                color: const Color(0xFFEFF6FF),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_rounded, size: 48),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.14),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 24,
            child: Text(
              'To: $toName',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 86,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Text(
              'From: $fromName',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
