import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class LoadThemePreference {
    final ThemeRepository repository;

    const LoadThemePreference(this.repository);

    Future<ThemePreference?> execute() => repository.loadThemePreference();
}
