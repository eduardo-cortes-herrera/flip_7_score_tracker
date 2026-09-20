import 'package:hive/hive.dart';

import '../../domain/entities/theme_preference.dart';

part 'theme_preference_model.g.dart';

@HiveType(typeId: 5)
class ThemePreferenceModel {
    @HiveField(0)
    final String themeId;

    @HiveField(1)
    final String mode;

    const ThemePreferenceModel({
        required this.themeId,
        required this.mode,
    });

    factory ThemePreferenceModel.fromEntity(ThemePreference preference) {
        return ThemePreferenceModel(
            themeId: preference.themeId,
            mode: preference.mode.name,
        );
    }

    ThemePreference toEntity() {
        return ThemePreference(
            themeId: themeId,
            mode: AppThemeMode.values.byName(mode),
        );
    }
}
