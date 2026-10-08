import 'package:flutter/material.dart';

import '../theme.dart';

class BrandedBackground extends StatelessWidget {
  final Widget child;
  final bool vivid;
  const BrandedBackground({super.key, required this.child, this.vivid = false});

  @override
  Widget build(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<_BackgroundScope>() != null)
      return child;
    return _BackgroundScope(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: takiCream,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: vivid
                ? const [
                    Color(0xFFFFE6A8),
                    Color(0xFFD5F3ED),
                    Color(0xFF9DDED7),
                  ]
                : const [
                    Color(0xFFFFFCF3),
                    Color(0xFFF2FBF8),
                    Color(0xFFEAF7F5),
                  ],
            stops: [0, .58, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -80,
              child: _Glow(
                color: vivid
                    ? const Color(0x5510AAA5)
                    : const Color(0x3308A7A1),
                size: 270,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _Glow(
                color: vivid
                    ? const Color(0x55FFA51F)
                    : const Color(0x25FFA51F),
                size: 300,
              ),
            ),
            const Positioned(
              top: 270,
              left: -105,
              child: _Glow(color: Color(0x1208A7A1), size: 190),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _BackgroundScope extends InheritedWidget {
  const _BackgroundScope({required super.child});
  @override
  bool updateShouldNotify(_BackgroundScope oldWidget) => false;
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class SectionBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const SectionBadge({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: takiMint,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: takiTealDark, size: 18),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            color: takiTealDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class TakiHeroHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accent;
  const TakiHeroHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.icon = Icons.auto_awesome,
    this.accent,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: (accent ?? takiTeal).withValues(alpha: .15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent ?? takiTealDark, size: 18),
            const SizedBox(width: 7),
            Text(
              eyebrow,
              style: TextStyle(
                color: accent ?? takiTealDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.displaySmall),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle!,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF617577),
          ),
        ),
      ],
    ],
  );
}

class TakiPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const TakiPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? const Color(0xFFFFFEFA),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white.withValues(alpha: .8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18083B46),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class TakiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Widget? action;
  const TakiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: TakiPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: takiMint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: takiTealDark),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: takiTealDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF617577),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    ),
  );
}
