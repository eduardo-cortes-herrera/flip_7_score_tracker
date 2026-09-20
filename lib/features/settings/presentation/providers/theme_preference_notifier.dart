import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/theme_preference.dart';
import 'theme_providers.dart';

class ThemePreferenceNotifier extends AsyncNotifier<ThemePreference> {
    @override
    Future<ThemePreference> build() async {
        final saved = await ref.read(loadThemePreferenceUseCaseProvider).execute();
        return saved ?? const ThemePreference(themeId: 'classic');
    }

    Future<void> setThemeId(String themeId) async {
        final current = state.value;
        if (current == null) return;
        await _update(current.copyWith(themeId: themeId));
    }

    Future<void> setMode(AppThemeMode mode) async {
        final current = state.value;
        if (current == null) return;
        await _update(current.copyWith(mode: mode));
    }

    Future<void> _update(ThemePreference preference) async {
        state = AsyncData(preference);
        await ref.read(saveThemePreferenceUseCaseProvider).execute(preference);
    }
}

final themePreferenceProvider =
    AsyncNotifierProvider<ThemePreferenceNotifier, ThemePreference>(
        ThemePreferenceNotifier.new,
    );
