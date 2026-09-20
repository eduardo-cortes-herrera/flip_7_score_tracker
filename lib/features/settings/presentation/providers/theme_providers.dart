import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/use_cases/load_theme_preference.dart';
import '../../domain/use_cases/save_theme_preference.dart';

final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
    return HiveThemeLocalDataSource();
});

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
    return ThemeRepositoryImpl(ref.watch(themeLocalDataSourceProvider));
});

final loadThemePreferenceUseCaseProvider = Provider((ref) {
    return LoadThemePreference(ref.watch(themeRepositoryProvider));
});

final saveThemePreferenceUseCaseProvider = Provider((ref) {
    return SaveThemePreference(ref.watch(themeRepositoryProvider));
});
