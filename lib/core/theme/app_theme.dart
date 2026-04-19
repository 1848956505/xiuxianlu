import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 现代简约 + 修仙点缀 主题配置
class AppTheme {
  AppTheme._();

  // ===== 圆角 =====
  static const double radiusCard = 12.0;
  static const double radiusButton = 8.0;
  static const double radiusInput = 8.0;
  static const double radiusDialog = 20.0;
  static const double radiusFab = 16.0;

  // ===== 浅色主题（默认）=====
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryBg,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.gold,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.goldBg,
      onSecondaryContainer: AppColors.goldDark,
      tertiary: AppColors.mainline,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFF3E8FF),
      onTertiaryContainer: AppColors.mainline,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: AppColors.danger,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      surfaceContainerHigh: AppColors.lightSurfaceVariant,
      outline: AppColors.lightDivider,
      outlineVariant: AppColors.lightDivider,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBg: AppColors.lightBackground,
      cardColor: AppColors.lightCardBackground,
      appBarBg: AppColors.lightSurface,
      appBarFg: AppColors.lightTextPrimary,
      bottomNavBg: AppColors.lightSurface,
      navUnselected: AppColors.navUnselectedLight,
      dialogBg: AppColors.lightSurface,
      dividerColor: AppColors.lightDivider,
      inputFill: AppColors.lightSurfaceVariant,
      snackBarBg: AppColors.lightTextPrimary,
      snackBarFg: AppColors.lightSurface,
      progressBg: AppColors.progressBackgroundLight,
    );
  }

  // ===== 深色主题 =====
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.goldLight,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.goldDark,
      onSecondaryContainer: AppColors.goldLight,
      tertiary: AppColors.mainline,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.darkSurfaceVariant,
      onTertiaryContainer: AppColors.mainline,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFCA5A5),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerHighest: AppColors.darkCardBackground,
      surfaceContainerHigh: AppColors.darkSurfaceVariant,
      outline: AppColors.darkDivider,
      outlineVariant: AppColors.darkDivider,
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBg: AppColors.darkBackground,
      cardColor: AppColors.darkCardBackground,
      appBarBg: AppColors.darkSurface,
      appBarFg: AppColors.darkTextPrimary,
      bottomNavBg: AppColors.darkSurface,
      navUnselected: AppColors.navUnselectedDark,
      dialogBg: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,
      inputFill: AppColors.darkSurfaceVariant,
      snackBarBg: AppColors.darkCardBackground,
      snackBarFg: AppColors.darkTextPrimary,
      progressBg: AppColors.progressBackgroundDark,
    );
  }

  // ===== 公共主题构建 =====
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardColor,
    required Color appBarBg,
    required Color appBarFg,
    required Color bottomNavBg,
    required Color navUnselected,
    required Color dialogBg,
    required Color dividerColor,
    required Color inputFill,
    required Color snackBarBg,
    required Color snackBarFg,
    required Color progressBg,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,

      // ===== AppBar =====
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: appBarFg,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: appBarFg),
      ),

      // ===== Card =====
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isLight ? 0.5 : 0,
        shadowColor: isLight
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ===== ElevatedButton =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),

      // ===== TextButton =====
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ===== OutlinedButton =====
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ===== InputDecoration =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: isLight
              ? AppColors.lightTextHint
              : AppColors.darkTextHint,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ===== BottomNavigationBar =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavBg,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: navUnselected,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 0,
      ),

      // ===== NavigationBar (Material 3) =====
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bottomNavBg,
        indicatorColor: AppColors.primaryBg,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.navSelected,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: navUnselected,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.navSelected);
          }
          return IconThemeData(color: navUnselected);
        }),
        elevation: 0,
        height: 65,
      ),

      // ===== Checkbox =====
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.lightTextHint, width: 1.5),
        shape: const CircleBorder(),
      ),

      // ===== Divider =====
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 1,
      ),

      // ===== SnackBar =====
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBg,
        contentTextStyle: TextStyle(color: snackBarFg, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
      ),

      // ===== Dialog =====
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBg,
        elevation: isLight ? 8 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
        titleTextStyle: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: isLight
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
          fontSize: 15,
        ),
      ),

      // ===== FloatingActionButton =====
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFab),
        ),
      ),

      // ===== Switch =====
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return isLight
              ? AppColors.lightTextHint
              : AppColors.darkTextHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return isLight
              ? AppColors.lightDivider
              : AppColors.darkDivider;
        }),
      ),

      // ===== ProgressIndicator =====
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: progressBg,
      ),

      // ===== TabBar =====
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: isLight
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),

      // ===== TextTheme =====
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isLight
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: isLight
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: isLight
              ? AppColors.lightTextHint
              : AppColors.darkTextHint,
          fontSize: 11,
        ),
      ),

      // ===== Chip =====
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.lightSurfaceVariant
            : AppColors.darkSurfaceVariant,
        labelStyle: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ===== BottomSheet =====
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dialogBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        elevation: 0,
      ),

      // ===== PopupMenu =====
      popupMenuTheme: PopupMenuThemeData(
        color: dialogBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        textStyle: TextStyle(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          fontSize: 14,
        ),
      ),

      // ===== Tooltip =====
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          color: isLight
              ? AppColors.lightSurface
              : AppColors.darkSurface,
          fontSize: 12,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
