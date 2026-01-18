import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Creative MirrorMe Logo with stylized "M" and reflection effect
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon - Creative M with mirror effect on dark background
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.25),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
            border: Border.all(
              color: AppTheme.neonCyan.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: -10,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: CustomPaint(
              size: Size(size, size),
              painter: _MLogoPainter(),
            ),
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.18),
          // App Name with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                AppTheme.neonCyan,
                AppTheme.neonBlue,
                AppTheme.neonGreen,
              ],
            ).createShader(bounds),
            child: Text(
              'MirrorMe',
              style: AppTheme.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the stylized M logo - improved visibility
class _MLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background gradient overlay for depth
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.transparent,
          Colors.white.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw stylized "M" letter with strong neon glow
    final padding = size.width * 0.22;
    final topY = size.height * 0.25;
    final bottomY = size.height * 0.75;
    final midY = size.height * 0.48;

    final mPath = Path();

    // Left stroke of M
    mPath.moveTo(padding, bottomY);
    mPath.lineTo(padding, topY);

    // Left diagonal to center
    mPath.lineTo(center.dx, midY);

    // Right diagonal from center
    mPath.lineTo(size.width - padding, topY);

    // Right stroke of M
    mPath.lineTo(size.width - padding, bottomY);

    // Outer glow layer (strongest)
    final outerGlowPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.12);

    canvas.drawPath(mPath, outerGlowPaint);

    // Middle glow layer
    final midGlowPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.06);

    canvas.drawPath(mPath, midGlowPaint);

    // Inner glow layer
    final innerGlowPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03);

    canvas.drawPath(mPath, innerGlowPaint);

    // Main M stroke - bright white and very visible
    final mPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(mPath, mPaint);

    // Central mirror line - vertical line through center
    final mirrorLinePaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.7)
      ..strokeWidth = size.width * 0.015
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.01);

    canvas.drawLine(
      Offset(center.dx, size.height * 0.20),
      Offset(center.dx, size.height * 0.80),
      mirrorLinePaint,
    );

    // Reflection effect at bottom - mirrored M shape fading out
    final reflectionPath = Path();
    final reflectY = size.height * 0.82;
    final reflectHeight = size.height * 0.12;

    reflectionPath.moveTo(padding, reflectY);
    reflectionPath.lineTo(padding, reflectY + reflectHeight * 0.6);

    reflectionPath.moveTo(center.dx, reflectY - reflectHeight * 0.3);
    reflectionPath.lineTo(center.dx, reflectY + reflectHeight * 0.3);

    reflectionPath.moveTo(size.width - padding, reflectY);
    reflectionPath.lineTo(size.width - padding, reflectY + reflectHeight * 0.6);

    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.neonCyan.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, reflectY - reflectHeight, size.width, reflectHeight * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03);

    canvas.drawPath(reflectionPath, reflectionPaint);

    // Accent dots at corners for polish
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Top left accent
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15),
      size.width * 0.025,
      dotPaint,
    );

    // Top right accent
    final dotPaint2 = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.02,
      dotPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact logo for headers
class AppLogoCompact extends StatelessWidget {
  final double height;

  const AppLogoCompact({super.key, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: height,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height * 0.25),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
            border: Border.all(
              color: AppTheme.neonCyan.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: -3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height * 0.25),
            child: CustomPaint(
              size: Size(height, height),
              painter: _MLogoPainter(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.neonCyan, AppTheme.neonBlue, AppTheme.neonGreen],
          ).createShader(bounds),
          child: Text(
            'MirrorMe',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated logo for splash screen
class AppLogoAnimated extends StatefulWidget {
  final double size;
  final bool showText;

  const AppLogoAnimated({super.key, this.size = 100, this.showText = true});

  @override
  State<AppLogoAnimated> createState() => _AppLogoAnimatedState();
}

class _AppLogoAnimatedState extends State<AppLogoAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.neonCyan.withOpacity(0.5 + 0.2 * _glowAnimation.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(_glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(_glowAnimation.value * 0.8),
                    blurRadius: 35,
                    spreadRadius: -10,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _MLogoPainter(),
                ),
              ),
            ),
            if (widget.showText) ...[
              SizedBox(height: widget.size * 0.18),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppTheme.neonCyan,
                    AppTheme.neonBlue,
                    AppTheme.neonGreen,
                  ],
                ).createShader(bounds),
                child: Text(
                  'MirrorMe',
                  style: AppTheme.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
