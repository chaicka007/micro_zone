import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _primaryColor = Color.fromARGB(255, 96, 194, 169);

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: _primaryColor,
    brightness: Brightness.light,
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: _colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: _colorScheme.primary,
          foregroundColor: _colorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android: тёмные иконки
            statusBarBrightness: Brightness.light, // iOS: тёмные иконки
          ),
          titleTextStyle: TextStyle(
            color: _colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: _colorScheme.onPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorScheme.primary,
            foregroundColor: _colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _colorScheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colorScheme.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: _colorScheme.onSurfaceVariant),
        ),
        cardTheme: CardThemeData(
          color: _colorScheme.surfaceContainerLow,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _colorScheme.surfaceContainer,
          elevation: 8,
          shadowColor: Colors.black12,
          indicatorColor: _colorScheme.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? _colorScheme.primary
                  : _colorScheme.onSurfaceVariant,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected
                  ? _colorScheme.primary
                  : _colorScheme.onSurfaceVariant,
            );
          }),
        ),
      );
}
