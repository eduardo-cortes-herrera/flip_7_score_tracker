import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/app_constants.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/domain/entities/game_mode.dart';
import '../../../game/domain/entities/player.dart';
import '../../../game/domain/entities/player_sort_mode.dart';
import '../../../game/presentation/providers/active_game_notifier.dart';
import '../../domain/entities/theme_preference.dart';
import '../providers/theme_preference_notifier.dart';
import '../theme/app_theme.dart';
import 'theme_settings_screen.dart';

String _modeLabel(GameMode mode) {
    switch (mode) {
        case GameMode.classic:
            return 'Classic';
        case GameMode.vengeance:
            return 'Vengeance';
        case GameMode.mixed:
            return 'Mixed';
    }
}

String _sortModeLabel(PlayerSortMode sortMode) {
    switch (sortMode) {
        case PlayerSortMode.listOrder:
            return 'List order';
        case PlayerSortMode.byScore:
            return 'By score';
    }
}

String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
        case AppThemeMode.light:
            return 'Light';
        case AppThemeMode.dark:
            return 'Dark';
        case AppThemeMode.system:
            return 'System';
    }
}

class SettingsScreen extends ConsumerWidget {
    const SettingsScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final gameAsync = ref.watch(activeGameProvider);

        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            appBar: AppBar(title: const Text('Settings')),
            body: gameAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (game) => _SettingsBody(game: game),
            ),
        );
    }
}

class _SettingsBody extends ConsumerWidget {
    final Game? game;

    const _SettingsBody({required this.game});

    void _apply(
        WidgetRef ref, {
        GameMode? mode,
        int? targetScore,
        PlayerSortMode? sortMode,
    }) {
        final notifier = ref.read(activeGameProvider.notifier);
        if (game == null) {
            notifier.startGame(
                mode: mode ?? defaultGameMode,
                targetScore: targetScore ?? defaultTargetScore,
            );
        } else {
            notifier.updateSettings(
                mode: mode,
                targetScore: targetScore,
                sortMode: sortMode,
            );
        }
    }

    Future<void> _pickMode(BuildContext context, WidgetRef ref) async {
        final current = game?.mode ?? defaultGameMode;
        final selected = await showModalBottomSheet<GameMode>(
            context: context,
            builder: (context) => SafeArea(
                child: RadioGroup<GameMode>(
                    groupValue: current,
                    onChanged: (value) => Navigator.of(context).pop(value),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: GameMode.values
                            .map(
                                (mode) => RadioListTile<GameMode>(
                                    value: mode,
                                    title: Text(_modeLabel(mode)),
                                ),
                            )
                            .toList(),
                    ),
                ),
            ),
        );

        if (selected != null) _apply(ref, mode: selected);
    }

    Future<void> _pickTargetScore(BuildContext context, WidgetRef ref) async {
        final controller = TextEditingController(
            text: (game?.targetScore ?? defaultTargetScore).toString(),
        );
        final value = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Target score'),
                content: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Score'),
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        child: const Text('Save'),
                    ),
                ],
            ),
        );

        final targetScore = value == null ? null : int.tryParse(value);
        if (targetScore != null && targetScore > 0) {
            _apply(ref, targetScore: targetScore);
        }
    }

    Future<void> _pickPlayerSortMode(BuildContext context, WidgetRef ref) async {
        final current = game?.sortMode ?? PlayerSortMode.listOrder;
        final selected = await showModalBottomSheet<PlayerSortMode>(
            context: context,
            builder: (context) => SafeArea(
                child: RadioGroup<PlayerSortMode>(
                    groupValue: current,
                    onChanged: (value) => Navigator.of(context).pop(value),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: PlayerSortMode.values
                            .map(
                                (sortMode) => RadioListTile<PlayerSortMode>(
                                    value: sortMode,
                                    title: Text(_sortModeLabel(sortMode)),
                                ),
                            )
                            .toList(),
                    ),
                ),
            ),
        );

        if (selected != null) _apply(ref, sortMode: selected);
    }

    Future<void> _confirmRestartGame(BuildContext context, WidgetRef ref) async {
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Restart game'),
                content: const Text(
                    'This will clear all rounds and scores. Players will be kept.',
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Restart'),
                    ),
                ],
            ),
        );

        if (confirmed == true) {
            await ref.read(activeGameProvider.notifier).resetGame();
        }
    }

    Future<void> _addPlayer(BuildContext context, WidgetRef ref) async {
        final controller = TextEditingController();
        final name = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Add player'),
                content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        child: const Text('Add'),
                    ),
                ],
            ),
        );

        if (name == null || name.trim().isEmpty) return;

        final notifier = ref.read(activeGameProvider.notifier);
        final player = Player(id: const Uuid().v4(), name: name.trim());

        if (game == null) {
            await notifier.startGame(
                mode: defaultGameMode,
                targetScore: defaultTargetScore,
            );
        }
        await notifier.addPlayer(player);
    }

    Future<void> _editPlayer(
        BuildContext context,
        WidgetRef ref,
        Player player,
    ) async {
        final controller = TextEditingController(text: player.name);
        final name = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Edit player'),
                content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        child: const Text('Save'),
                    ),
                ],
            ),
        );

        if (name == null || name.trim().isEmpty) return;

        await ref
            .read(activeGameProvider.notifier)
            .renamePlayer(player.id, name.trim());
    }

    Future<void> _confirmRemoveAllPlayers(
        BuildContext context,
        WidgetRef ref,
    ) async {
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Remove all players'),
                content: const Text(
                    'This will remove every player and clear all rounds.',
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Remove all'),
                    ),
                ],
            ),
        );

        if (confirmed == true) {
            await ref.read(activeGameProvider.notifier).removeAllPlayers();
        }
    }

    void _showError(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> _rateOnPlayStore(BuildContext context) async {
        final marketUri = Uri.parse('market://details?id=$packageId');
        final webUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=$packageId',
        );
        try {
            final launched = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
            if (launched) return;
        } catch (_) {
            // Fall through to the web URL below.
        }
        try {
            final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
            if (!launched && context.mounted) {
                _showError(context, 'Could not open the Play Store.');
            }
        } catch (_) {
            if (context.mounted) _showError(context, 'Could not open the Play Store.');
        }
    }

    Future<void> _openBuyMeACoffee(BuildContext context) async {
        final uri = Uri.parse(buyMeACoffeeUrl);
        try {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!launched && context.mounted) {
                _showError(context, 'Could not open the link.');
            }
        } catch (_) {
            if (context.mounted) _showError(context, 'Could not open the link.');
        }
    }

    Future<void> _sendFeedback(BuildContext context) async {
        final uri = Uri(
            scheme: 'mailto',
            path: feedbackEmail,
            query: 'subject=$appName feedback',
        );
        try {
            final launched = await launchUrl(uri);
            if (!launched && context.mounted) {
                _showError(context, 'Could not open an email app.');
            }
        } catch (_) {
            if (context.mounted) _showError(context, 'Could not open an email app.');
        }
    }

    Future<void> _shareApp(BuildContext context) async {
        try {
            await SharePlus.instance.share(
                ShareParams(
                    text: 'Track scores for Flip 7 with $appName!',
                ),
            );
        } catch (_) {
            if (context.mounted) _showError(context, 'Could not open the share sheet.');
        }
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final colorScheme = Theme.of(context).colorScheme;
        final players = game?.players ?? const <Player>[];
        final themePreferenceAsync = ref.watch(themePreferenceProvider);
        final themePreference = themePreferenceAsync.value;

        return ListView(
            padding: const EdgeInsets.all(16),
            children: [
                Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                        children: [
                            _SettingsTile(
                                icon: Icons.style_outlined,
                                label: 'Game mode',
                                value: _modeLabel(game?.mode ?? defaultGameMode),
                                onTap: () => _pickMode(context, ref),
                            ),
                            const Divider(height: 1, indent: 56),
                            _SettingsTile(
                                icon: Icons.flag_outlined,
                                label: 'Target score',
                                value: '${game?.targetScore ?? defaultTargetScore}',
                                onTap: () => _pickTargetScore(context, ref),
                            ),
                        ],
                    ),
                ),
                const SizedBox(height: 24),
                Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: _SettingsTile(
                        icon: Icons.palette_outlined,
                        label: 'Theme',
                        value: themePreference == null
                            ? ''
                            : '${appThemeById(themePreference.themeId).name} · '
                                '${_themeModeLabel(themePreference.mode)}',
                        onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ThemeSettingsScreen(),
                                ),
                            );
                        },
                    ),
                ),
                const SizedBox(height: 24),
                Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                        children: [
                            _SettingsTile(
                                icon: Icons.sort,
                                label: 'Player order',
                                value: _sortModeLabel(
                                    game?.sortMode ?? PlayerSortMode.listOrder,
                                ),
                                onTap: () => _pickPlayerSortMode(context, ref),
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                                leading: Icon(Icons.person_add_outlined,
                                    color: colorScheme.onSurface),
                                title: const Text('Add player'),
                                onTap: () => _addPlayer(context, ref),
                            ),
                            if (players.isNotEmpty) ...[
                                const Divider(height: 1, indent: 56),
                                ReorderableListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    buildDefaultDragHandles: false,
                                    itemCount: players.length,
                                    itemBuilder: (context, index) {
                                        final player = players[index];
                                        return ListTile(
                                            key: ValueKey(player.id),
                                            leading: ReorderableDragStartListener(
                                                index: index,
                                                child: const Icon(Icons.drag_handle),
                                            ),
                                            title: Text(player.name),
                                            onTap: () => _editPlayer(context, ref, player),
                                            trailing: IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () => ref
                                                    .read(activeGameProvider.notifier)
                                                    .removePlayer(player.id),
                                            ),
                                        );
                                    },
                                    onReorderItem: (oldIndex, newIndex) {
                                        final reordered = [...players];
                                        final moved = reordered.removeAt(oldIndex);
                                        reordered.insert(newIndex, moved);
                                        ref
                                            .read(activeGameProvider.notifier)
                                            .reorderPlayers(reordered);
                                    },
                                ),
                            ],
                        ],
                    ),
                ),
                const SizedBox(height: 24),
                Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                        children: [
                            ListTile(
                                leading: Icon(Icons.star_outline, color: colorScheme.onSurface),
                                title: const Text('Rate on Play Store'),
                                onTap: () => _rateOnPlayStore(context),
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                                leading: Icon(Icons.share_outlined, color: colorScheme.onSurface),
                                title: const Text('Share app'),
                                onTap: () => _shareApp(context),
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                                leading: Icon(Icons.mail_outline, color: colorScheme.onSurface),
                                title: const Text('Send feedback'),
                                onTap: () => _sendFeedback(context),
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                                leading: Icon(Icons.coffee_outlined, color: colorScheme.onSurface),
                                title: const Text('Buy me a coffee'),
                                onTap: () => _openBuyMeACoffee(context),
                            ),
                        ],
                    ),
                ),
                const SizedBox(height: 24),
                Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                        children: [
                            ListTile(
                                leading: Icon(Icons.refresh, color: colorScheme.error),
                                title: Text(
                                    'Restart game',
                                    style: TextStyle(color: colorScheme.error),
                                ),
                                onTap: () => _confirmRestartGame(context, ref),
                            ),
                            if (players.isNotEmpty) ...[
                                const Divider(height: 1, indent: 56),
                                ListTile(
                                    leading: Icon(
                                        Icons.person_remove_outlined,
                                        color: colorScheme.error,
                                    ),
                                    title: Text(
                                        'Remove all players',
                                        style: TextStyle(color: colorScheme.error),
                                    ),
                                    onTap: () => _confirmRemoveAllPlayers(context, ref),
                                ),
                            ],
                        ],
                    ),
                ),
            ],
        );
    }
}

class _SettingsTile extends StatelessWidget {
    final IconData icon;
    final String label;
    final String value;
    final VoidCallback onTap;

    const _SettingsTile({
        required this.icon,
        required this.label,
        required this.value,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return ListTile(
            leading: Icon(icon, color: colorScheme.onSurface),
            title: Text(label),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                        value,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                    ),
                ],
            ),
            onTap: onTap,
        );
    }
}
