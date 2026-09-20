import 'package:hive/hive.dart';

import '../models/theme_preference_model.dart';

abstract class ThemeLocalDataSource {
    Future<void> saveThemePreference(ThemePreferenceModel preference);

    Future<ThemePreferenceModel?> loadThemePreference();
}

class HiveThemeLocalDataSource implements ThemeLocalDataSource {
    static const String boxName = 'settings';
    static const String themePreferenceKey = 'theme_preference';

    Future<Box<ThemePreferenceModel>> _openBox() {
        return Hive.openBox<ThemePreferenceModel>(boxName);
    }

    @override
    Future<void> saveThemePreference(ThemePreferenceModel preference) async {
        final box = await _openBox();
        await box.put(themePreferenceKey, preference);
    }

    @override
    Future<ThemePreferenceModel?> loadThemePreference() async {
        final box = await _openBox();
        return box.get(themePreferenceKey);
    }
}
