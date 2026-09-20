import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';
import '../models/theme_preference_model.dart';

class ThemeRepositoryImpl implements ThemeRepository {
    final ThemeLocalDataSource localDataSource;

    const ThemeRepositoryImpl(this.localDataSource);

    @override
    Future<void> saveThemePreference(ThemePreference preference) {
        return localDataSource.saveThemePreference(
            ThemePreferenceModel.fromEntity(preference),
        );
    }

    @override
    Future<ThemePreference?> loadThemePreference() async {
        final model = await localDataSource.loadThemePreference();
        return model?.toEntity();
    }
}
