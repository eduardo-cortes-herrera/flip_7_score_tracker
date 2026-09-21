import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_constants.dart';
import '../../../calculator/presentation/widgets/calculator_toggle_tile.dart';
import '../../../game/domain/entities/player.dart';
import '../../../game/presentation/providers/active_game_notifier.dart';
import '../../../game/presentation/widgets/player_card.dart';
import '../../domain/entities/theme_preference.dart';
import '../providers/theme_preference_notifier.dart';
import '../theme/app_theme.dart';

String _modeLabel(AppThemeMode mode) {
    switch (mode) {
        case AppThemeMode.light:
            return 'Light';
        case AppThemeMode.dark:
            return 'Dark';
        case AppThemeMode.system:
            return 'System';
    }
}

Brightness _resolveBrightness(BuildContext context, AppThemeMode mode) {
    switch (mode) {
        case AppThemeMode.light:
            return Brightness.light;
        case AppThemeMode.dark:
            return Brightness.dark;
        case AppThemeMode.system:
            return MediaQuery.platformBrightnessOf(context);
    }
}

class ThemeSettingsScreen extends ConsumerWidget {
    const ThemeSettingsScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final preferenceAsync = ref.watch(themePreferenceProvider);

        return Scaffold(
            appBar: AppBar(title: const Text('Theme')),
            body: preferenceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (preference) => _ThemeSettingsBody(preference: preference),
            ),
        );
    }
}

class _ThemeSettingsBody extends ConsumerWidget {
    final ThemePreference preference;

    const _ThemeSettingsBody({required this.preference});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final brightness = _resolveBrightness(context, preference.mode);
        final gameAsync = ref.watch(activeGameProvider);
        final game = gameAsync.value;
        final previewPlayer = game?.leader ?? game?.players.firstOrNull;

        return ListView(
            padding: const EdgeInsets.all(16),
            children: [
                PlayerCard(
                    player: previewPlayer ?? _placeholderPlayer,
                    totalScore: previewPlayer != null
                        ? game!.totalScoreForPlayer(previewPlayer.id)
                        : 94,
                    targetScore: game?.targetScore ?? defaultTargetScore,
                    roundsPlayed: previewPlayer != null ? game!.rounds.length : 3,
                    roundScores: previewPlayer != null
                        ? [for (final round in game!.rounds) round.scoreForPlayer(previewPlayer.id)]
                        : const [32, null, 62],
                    isLeader: previewPlayer != null && game?.leader?.id == previewPlayer.id,
                    onTap: () {},
                    onEditRoundScore: (roundNumber, currentScore) {},
                    onEditPlayer: () {},
                    onRemovePlayer: () {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                    height: 56,
                    child: Row(
                        children: [
                            Expanded(
                                child: CalculatorToggleTile(
                                    label: '1',
                                    selected: true,
                                    onTap: () {},
                                ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: CalculatorToggleTile(
                                    label: '2',
                                    selected: false,
                                    onTap: () {},
                                ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: CalculatorToggleTile(
                                    label: '3',
                                    selected: false,
                                    onTap: () {},
                                ),
                            ),
                        ],
                    ),
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),
                SizedBox(
                    height: 108,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableAppThemes.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                            final appTheme = availableAppThemes[index];
                            final selected = appTheme.id == preference.themeId;
                            return _ThemeSwatch(
                                appTheme: appTheme,
                                brightness: brightness,
                                selected: selected,
                                onTap: () => ref
                                    .read(themePreferenceProvider.notifier)
                                    .setThemeId(appTheme.id),
                            );
                        },
                    ),
                ),
                const SizedBox(height: 20),
                SegmentedButton<AppThemeMode>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    segments: AppThemeMode.values
                        .map(
                            (mode) => ButtonSegment(
                                value: mode,
                                label: Text(_modeLabel(mode)),
                            ),
                        )
                        .toList(),
                    selected: {preference.mode},
                    onSelectionChanged: (selection) {
                        ref
                            .read(themePreferenceProvider.notifier)
                            .setMode(selection.first);
                    },
                ),
            ],
        );
    }
}

const _placeholderPlayer = Player(id: 'preview', name: 'Player');

class _ThemeSwatch extends StatelessWidget {
    final AppTheme appTheme;
    final Brightness brightness;
    final bool selected;
    final VoidCallback onTap;

    const _ThemeSwatch({
        required this.appTheme,
        required this.brightness,
        required this.selected,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final scheme = appTheme.colorScheme(brightness);
        final outline = Theme.of(context).colorScheme.primary;

        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
                children: [
                    Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: selected ? outline : scheme.outlineVariant,
                                width: selected ? 2 : 1,
                            ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Container(
                                    width: 22,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: scheme.primary,
                                        borderRadius: BorderRadius.circular(4),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                    width: 36,
                                    height: 6,
                                    color: scheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                    width: 26,
                                    height: 6,
                                    color: scheme.onSurface.withValues(alpha: 0.2),
                                ),
                                const Spacer(),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                            color: scheme.secondary,
                                            shape: BoxShape.circle,
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        appTheme.name,
                        style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
            ),
        );
    }
}
