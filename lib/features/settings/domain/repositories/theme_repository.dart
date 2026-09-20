import '../entities/theme_preference.dart';

abstract class ThemeRepository {
    Future<void> saveThemePreference(ThemePreference preference);

    Future<ThemePreference?> loadThemePreference();
}
