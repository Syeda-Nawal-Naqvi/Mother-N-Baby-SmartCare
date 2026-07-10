import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // ── Light Theme ───────────────────────────────────────────────────────
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE91E8C),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF0F5),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF3D1A2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF3D1A2E),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFE91E8C);
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFE91E8C).withValues(alpha: 0.4);
        }
        return Colors.grey.shade200;
      }),
    ),
    dividerColor: const Color(0xFFF5F5F5),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // ── Dark Theme — deep purple + dark pink palette ───────────────────────
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE91E8C),
      brightness: Brightness.dark,
    ).copyWith(
      // override key surfaces with our purple palette
      surface: const Color(0xFF2A1A2E),
      onSurface: const Color(0xFFF5E6F5),
      primary: const Color(0xFFE91E8C),
      secondary: const Color(0xFFB39DDB), // lavender accent
      tertiary: const Color(0xFF9C27B0), // purple accent
      surfaceContainerHighest: const Color(0xFF3D1A3A),
    ),

    // ── Backgrounds ──────────────────────────────────────────────────
    scaffoldBackgroundColor: const Color(0xFF1A0D1E), // deep purple-black
    cardColor: const Color(0xFF2A1A2E), // dark purple card

    // ── AppBar ───────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE91E8C)),
      titleTextStyle: TextStyle(
        color: Color(0xFFF5E6F5),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ── Switch ───────────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFE91E8C);
        }
        return const Color(0xFF6B3A6B);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFE91E8C).withValues(alpha: 0.4);
        }
        return const Color(0xFF3D1A3A);
      }),
    ),

    // ── Divider ──────────────────────────────────────────────────────
    dividerColor: const Color(0xFF3D1A3A),

    // ── Input fields ─────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3D1A3A),
      hintStyle: const TextStyle(color: Color(0xFF9E5E9E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B2D5E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B2D5E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 1.5),
      ),
    ),

    // ── Dialog ───────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF2A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // ── Text ─────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF5E6F5)),
      bodyMedium: TextStyle(color: Color(0xFFB08AB8)),
      titleMedium: TextStyle(color: Color(0xFFF5E6F5)),
    ),
  );
}
