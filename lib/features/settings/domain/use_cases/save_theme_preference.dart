import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class SaveThemePreference {
    final ThemeRepository repository;

    const SaveThemePreference(this.repository);

    Future<void> execute(ThemePreference preference) {
        return repository.saveThemePreference(preference);
    }
}
