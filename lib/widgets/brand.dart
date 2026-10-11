import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../theme/app_theme.dart';

/// Rounded gradient app mark with a "nook" (bookmark + star) glyph.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CustomPaint(painter: _NookPainter()),
    );
  }
}

class _NookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // Bookmark/nook shape with a notch cut from the bottom.
    final Path nook = Path()
      ..moveTo(w * 0.33, h * 0.22)
      ..lineTo(w * 0.67, h * 0.22)
      ..quadraticBezierTo(w * 0.73, h * 0.22, w * 0.73, h * 0.30)
      ..lineTo(w * 0.73, h * 0.78)
      ..lineTo(w * 0.5, h * 0.62)
      ..lineTo(w * 0.27, h * 0.78)
      ..lineTo(w * 0.27, h * 0.30)
      ..quadraticBezierTo(w * 0.27, h * 0.22, w * 0.33, h * 0.22)
      ..close();
    canvas.drawPath(nook, fill);

    // A small star accent punched out near the top-left of the bookmark.
    final Paint cut = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.clear;
    canvas.drawPath(_star(Offset(w * 0.5, h * 0.42), h * 0.10), cut);
  }

  Path _star(Offset c, double r) {
    final Path path = Path();
    for (int i = 0; i < 10; i++) {
      final double radius = i.isEven ? r : r * 0.45;
      final double angle = (math.pi / 5) * i - math.pi / 2;
      final double x = c.dx + radius * math.cos(angle);
      final double y = c.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark row used in headers.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.showSubtitle = true});

  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const BrandMark(size: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            if (showSubtitle)
              const Text(
                AppInfo.tagline,
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
          ],
        ),
      ],
    );
  }
}

/// Small pill badge.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color = AppTheme.accent2,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Privacy reassurance chip shown in the header.
class OfflineChip extends StatelessWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified_user_outlined, size: 15, color: AppTheme.accent2),
          SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
