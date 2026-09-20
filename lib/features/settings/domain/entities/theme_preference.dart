enum AppThemeMode {
    light,
    system,
    dark,
}

class ThemePreference {
    final String themeId;
    final AppThemeMode mode;

    const ThemePreference({
        required this.themeId,
        this.mode = AppThemeMode.system,
    });

    ThemePreference copyWith({
        String? themeId,
        AppThemeMode? mode,
    }) {
        return ThemePreference(
            themeId: themeId ?? this.themeId,
            mode: mode ?? this.mode,
        );
    }
}
