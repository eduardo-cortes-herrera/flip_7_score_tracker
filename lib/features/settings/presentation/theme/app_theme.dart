import 'package:flutter/material.dart';

class AppTheme {
    final String id;
    final String name;
    final Color seedColor;

    /// Overrides the default seed-based generation. Used by themes (like
    /// [_monochromeScheme]) that need exact colors instead of whatever hue
    /// Material's algorithm derives from the seed.
    final ColorScheme Function(Brightness brightness)? buildColorScheme;

    const AppTheme({
        required this.id,
        required this.name,
        required this.seedColor,
        this.buildColorScheme,
    });

    ColorScheme colorScheme(Brightness brightness) {
        if (buildColorScheme != null) return buildColorScheme!(brightness);
        return ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: brightness,
        );
    }
}

/// A true black/white/gray scheme. `ColorScheme.fromSeed` can't do this on
/// its own: Material's algorithm falls back to a default (blue-ish) hue for
/// achromatic seeds, so even `Colors.grey` ends up with a visible tint.
ColorScheme _monochromeScheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
        return ColorScheme.dark(
            primary: const Color(0xFFE0E0E0),
            onPrimary: const Color(0xFF1A1A1A),
            primaryContainer: const Color(0xFF3A3A3A),
            onPrimaryContainer: const Color(0xFFF5F5F5),
            secondary: const Color(0xFFBDBDBD),
            onSecondary: const Color(0xFF1A1A1A),
            secondaryContainer: const Color(0xFF2E2E2E),
            onSecondaryContainer: const Color(0xFFE0E0E0),
            tertiary: const Color(0xFF9E9E9E),
            onTertiary: const Color(0xFF1A1A1A),
            tertiaryContainer: const Color(0xFF424242),
            onTertiaryContainer: const Color(0xFFEEEEEE),
            surface: const Color(0xFF121212),
            onSurface: const Color(0xFFE0E0E0),
            surfaceContainerLowest: const Color(0xFF0A0A0A),
            surfaceContainerLow: const Color(0xFF1A1A1A),
            surfaceContainer: const Color(0xFF1F1F1F),
            surfaceContainerHigh: const Color(0xFF2A2A2A),
            surfaceContainerHighest: const Color(0xFF353535),
            onSurfaceVariant: const Color(0xFFBDBDBD),
            outline: const Color(0xFF8A8A8A),
            outlineVariant: const Color(0xFF444444),
            inverseSurface: const Color(0xFFE0E0E0),
            onInverseSurface: const Color(0xFF1A1A1A),
            inversePrimary: const Color(0xFF424242),
        );
    }

    return ColorScheme.light(
        primary: const Color(0xFF2A2A2A),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFE0E0E0),
        onPrimaryContainer: const Color(0xFF1A1A1A),
        secondary: const Color(0xFF5C5C5C),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE8E8E8),
        onSecondaryContainer: const Color(0xFF2A2A2A),
        tertiary: const Color(0xFF757575),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFEEEEEE),
        onTertiaryContainer: const Color(0xFF2A2A2A),
        surface: const Color(0xFFFAFAFA),
        onSurface: const Color(0xFF1A1A1A),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF5F5F5),
        surfaceContainer: const Color(0xFFEFEFEF),
        surfaceContainerHigh: const Color(0xFFE8E8E8),
        surfaceContainerHighest: const Color(0xFFE0E0E0),
        onSurfaceVariant: const Color(0xFF444444),
        outline: const Color(0xFF757575),
        outlineVariant: const Color(0xFFC7C7C7),
        inverseSurface: const Color(0xFF2A2A2A),
        onInverseSurface: const Color(0xFFF5F5F5),
        inversePrimary: const Color(0xFFCCCCCC),
    );
}

/// The catalog of visual themes available in the app.
///
/// To add your own theme: add a new [AppTheme] entry below with a unique
/// [AppTheme.id] and a seed [Color] — it will automatically show up in
/// Settings > Theme with a live preview, no other code changes needed. (Only
/// use [AppTheme.buildColorScheme] if you need exact colors that
/// `ColorScheme.fromSeed` can't produce, like a true grayscale palette.)
const List<AppTheme> availableAppThemes = [
    AppTheme(
        id: 'system',
        name: 'System',
        seedColor: Colors.grey,
        buildColorScheme: _monochromeScheme,
    ),
    AppTheme(
        id: 'classic',
        name: 'Classic',
        seedColor: Colors.blue,
    ),
    AppTheme(
        id: 'ocean',
        name: 'Ocean',
        seedColor: Color(0xFF2E7D8C),
    ),
    AppTheme(
        id: 'forest',
        name: 'Forest',
        seedColor: Color(0xFF2E7D32),
    ),
    AppTheme(
        id: 'sand',
        name: 'Sand',
        seedColor: Color(0xFFC8A165),
    ),
    AppTheme(
        id: 'ruby',
        name: 'Ruby',
        seedColor: Color(0xFFC62828),
    ),
    AppTheme(
        id: 'sapphire',
        name: 'Sapphire',
        seedColor: Color(0xFF1A237E),
    ),
    AppTheme(
        id: 'pearl',
        name: 'Pearl',
        seedColor: Color(0xFFEAE0C8),
    ),
    AppTheme(
        id: 'amethyst',
        name: 'Amethyst',
        seedColor: Color(0xFF7B1FA2),
    ),
    AppTheme(
        id: 'rose',
        name: 'Rose',
        seedColor: Color(0xFFEC407A),
    ),
];

AppTheme appThemeById(String id) {
    return availableAppThemes.firstWhere(
        (theme) => theme.id == id,
        orElse: () => availableAppThemes.first,
    );
}
