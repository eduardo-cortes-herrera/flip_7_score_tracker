import 'package:hive_flutter/hive_flutter.dart';

import 'models/theme_preference_model.dart';

void registerSettingsHiveAdapters() {
    if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ThemePreferenceModelAdapter());
    }
}
