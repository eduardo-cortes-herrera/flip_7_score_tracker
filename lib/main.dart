import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/app_constants.dart';
import 'features/game/data/hive_registrar.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/settings/data/hive_registrar.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/presentation/providers/theme_preference_notifier.dart';
import 'features/settings/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  registerGameHiveAdapters();
  registerSettingsHiveAdapters();

  runApp(const ProviderScope(child: MyApp()));
}

ThemeMode _toThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider).value ??
        const ThemePreference(themeId: defaultThemeId);
    final appTheme = appThemeById(preference.themeId);

    return MaterialApp(
      title: appName,
      theme: ThemeData(colorScheme: appTheme.colorScheme(Brightness.light)),
      darkTheme: ThemeData(colorScheme: appTheme.colorScheme(Brightness.dark)),
      themeMode: _toThemeMode(preference.mode),
      home: const GameScreen(),
    );
  }
}
