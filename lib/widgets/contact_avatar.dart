import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.gradientIndex = 0,
  });

  final String initials;
  final double size;
  final int gradientIndex;

  static const _gradients = [
    [AppColors.primaryLight, AppColors.primary],
    [Color(0xFF60A5FA), AppColors.primaryDark],
    [Color(0xFF818CF8), Color(0xFF6366F1)],
    [Color(0xFF34D399), Color(0xFF10B981)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[gradientIndex % _gradients.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
