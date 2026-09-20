import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calculator/presentation/screens/calculator_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/player_sort_mode.dart';
import '../../domain/entities/round.dart';
import '../providers/active_game_notifier.dart';
import '../widgets/player_card.dart';

String _sortModeLabel(PlayerSortMode sortMode) {
    switch (sortMode) {
        case PlayerSortMode.listOrder:
            return 'List order';
        case PlayerSortMode.byScore:
            return 'By score';
    }
}

class GameScreen extends ConsumerWidget {
    const GameScreen({super.key});

    void _showError(BuildContext context, Object error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
        );
    }

    Future<void> _pickPlayerSortMode(
        BuildContext context,
        WidgetRef ref,
        Game game,
    ) async {
        final selected = await showModalBottomSheet<PlayerSortMode>(
            context: context,
            builder: (context) => SafeArea(
                child: RadioGroup<PlayerSortMode>(
                    groupValue: game.sortMode,
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

        if (selected != null) {
            await ref.read(activeGameProvider.notifier).updateSettings(sortMode: selected);
        }
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

        await ref.read(activeGameProvider.notifier).renamePlayer(player.id, name.trim());
    }

    Round? _findOpenRound(Game game) {
        if (game.rounds.isEmpty) return null;
        final last = game.rounds.last;
        final hasPending = last.playerRounds.any((playerRound) => playerRound.score == null);
        return hasPending ? last : null;
    }

    /// Opens the calculator for [playerId] in round [roundNumber]. After a
    /// score is confirmed, if any other player in that same round still
    /// hasn't scored, the calculator opens again for them automatically.
    /// Only once every player in the round has a value does this return to
    /// the game screen.
    Future<void> _openCalculatorAndSave(
        BuildContext context,
        WidgetRef ref,
        GameMode mode, {
        required int roundNumber,
        required String playerId,
    }) async {
        String? currentPlayerId = playerId;

        while (currentPlayerId != null) {
            final game = ref.read(activeGameProvider).value;
            if (game == null) return;

            final round = game.rounds.where((r) => r.number == roundNumber).firstOrNull;
            if (round == null) return;

            final player = game.players.where((p) => p.id == currentPlayerId).firstOrNull;
            if (player == null) return;

            if (!context.mounted) return;
            final result = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                    builder: (_) => CalculatorScreen(
                        mode: mode,
                        playerName: player.name,
                        roundNumber: roundNumber,
                        initialScore: round.scoreForPlayer(player.id),
                    ),
                ),
            );

            if (result == null) return;
            if (!context.mounted) return;

            try {
                await ref.read(activeGameProvider.notifier).recordScore(
                    roundNumber: roundNumber,
                    playerId: player.id,
                    score: result,
                );
            } catch (error) {
                if (context.mounted) _showError(context, error);
                return;
            }

            final updatedGame = ref.read(activeGameProvider).value;
            final updatedRound =
                updatedGame?.rounds.where((r) => r.number == roundNumber).firstOrNull;
            currentPlayerId = updatedRound?.playerRounds
                .where((playerRound) => playerRound.score == null)
                .firstOrNull
                ?.playerId;
        }
    }

    Future<void> _onCardTap(
        BuildContext context,
        WidgetRef ref,
        Game game,
        Player player,
    ) async {
        Round round;
        final openRound = _findOpenRound(game);

        if (openRound != null) {
            round = openRound;
        } else {
            try {
                await ref.read(activeGameProvider.notifier).addRound();
            } catch (error) {
                if (context.mounted) _showError(context, error);
                return;
            }

            final updated = ref.read(activeGameProvider).value;
            if (updated == null || updated.rounds.isEmpty) return;
            round = updated.rounds.last;
        }

        if (!context.mounted) return;
        await _openCalculatorAndSave(
            context,
            ref,
            game.mode,
            roundNumber: round.number,
            playerId: player.id,
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final gameAsync = ref.watch(activeGameProvider);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Players'),
                actions: [
                    if (gameAsync.value != null)
                        IconButton(
                            icon: const Icon(Icons.sort),
                            tooltip: 'Player order',
                            onPressed: () =>
                                _pickPlayerSortMode(context, ref, gameAsync.value!),
                        ),
                    IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Settings',
                        onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                ),
                            );
                        },
                    ),
                ],
            ),
            body: gameAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (game) {
                    if (game == null || game.players.isEmpty) {
                        return const Center(
                            child: Text('Add players in Settings to get started.'),
                        );
                    }

                    return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        children: [
                            for (final player in game.orderedPlayers)
                                PlayerCard(
                                    player: player,
                                    totalScore: game.totalScoreForPlayer(player.id),
                                    targetScore: game.targetScore,
                                    roundsPlayed: game.rounds.length,
                                    roundScores: [
                                        for (final round in game.rounds)
                                            round.scoreForPlayer(player.id),
                                    ],
                                    isLeader: game.leader?.id == player.id,
                                    onTap: () => _onCardTap(context, ref, game, player),
                                    onEditRoundScore: (roundNumber, currentScore) =>
                                        _openCalculatorAndSave(
                                            context,
                                            ref,
                                            game.mode,
                                            roundNumber: roundNumber,
                                            playerId: player.id,
                                        ),
                                    onEditPlayer: () => _editPlayer(context, ref, player),
                                    onRemovePlayer: () => ref
                                        .read(activeGameProvider.notifier)
                                        .removePlayer(player.id),
                                ),
                        ],
                    );
                },
            ),
        );
    }
}
