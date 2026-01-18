import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// MirrorMe Cyberpunk Cinematic Theme
/// A stunning dark theme with neon accents, glass morphism, and futuristic aesthetics
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // CYBERPUNK COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════════════════

  // Primary Neon Colors
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPink = Color(0xFF00E5A8);
  static const Color neonPurple = Color(0xFF00C2FF);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonGreen = Color(0xFF00FF9F);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonYellow = Color(0xFFFFE600);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color backgroundDarker = Color(0xFF050810);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1A2332);
  static const Color cardDark = Color(0xFF151D2E);

  // Glass Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF00FF9F);
  static const Color error = Color(0xFFFF3D71);
  static const Color warning = Color(0xFFFFAA00);
  static const Color info = Color(0xFF00BFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, neonBlue],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonGreen, neonOrange],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundDarker],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2332), Color(0xFF111827)],
  );

  static const LinearGradient neonGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x4000F5FF), Color(0x4000BFFF)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x00FFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BOX SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> neonGlow(
    Color color, {
    double blur = 20,
    double spread = 0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(0.6),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: blur * 2,
        spreadRadius: spread,
      ),
    ];
  }

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: neonCyan.withOpacity(0.1),
      blurRadius: 40,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> glowingShadow = [
    BoxShadow(
      color: neonCyan.withOpacity(0.3),
      blurRadius: 30,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: neonPurple.withOpacity(0.2),
      blurRadius: 50,
      spreadRadius: -10,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? glassBorder, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration neonBorderDecoration({
    double borderRadius = 16,
    Color color = neonCyan,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: cardDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color, width: borderWidth),
      boxShadow: neonGlow(color, blur: 15),
    );
  }

  static BoxDecoration gradientDecoration({
    required Gradient gradient,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: cardShadow,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMuted,
    height: 1.4,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static TextStyle get neonText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: neonCyan,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData light() => darkTheme();

  static ThemeData dark() => darkTheme();

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        tertiary: neonPink,
        surface: surfaceDark,
        error: error,
        onPrimary: backgroundDark,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: labelLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: neonCyan),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: neonCyan,
              foregroundColor: backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ).copyWith(
              overlayColor: WidgetStateProperty.all(neonCyan.withOpacity(0.2)),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonCyan,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: neonCyan, width: 1.5),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonCyan,
          textStyle: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: GoogleFonts.rajdhani(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.rajdhani(color: textMuted, fontSize: 16),
        prefixIconColor: neonCyan,
        suffixIconColor: neonCyan,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: neonCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonCyan,
        foregroundColor: backgroundDark,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        labelStyle: GoogleFonts.rajdhani(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassBorder),
        ),
        titleTextStyle: headlineMedium,
        contentTextStyle: bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: surfaceDark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: neonCyan,
        linearTrackColor: surfaceLight,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonCyan,
        inactiveTrackColor: surfaceLight,
        thumbColor: neonCyan,
        overlayColor: neonCyan.withOpacity(0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonCyan;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return neonCyan.withOpacity(0.5);
          }
          return surfaceLight;
        }),
      ),
      dividerTheme: DividerThemeData(color: glassBorder, thickness: 1),
      iconTheme: const IconThemeData(color: neonCyan, size: 24),
    );
  }
}
