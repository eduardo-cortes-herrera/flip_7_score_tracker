import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/game.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/player_sort_mode.dart';
import 'game_providers.dart';

class ActiveGameNotifier extends AsyncNotifier<Game?> {
    @override
    Future<Game?> build() {
        return ref.read(loadGameUseCaseProvider).execute();
    }

    Future<void> startGame({
        required GameMode mode,
        required int targetScore,
    }) async {
        final createGame = ref.read(createGameUseCaseProvider);
        await _update(createGame.execute(mode: mode, targetScore: targetScore));
    }

    Future<void> addPlayer(Player player) async {
        final current = state.value;
        if (current == null) return;

        final addPlayer = ref.read(addPlayerUseCaseProvider);
        await _update(addPlayer.execute(game: current, player: player));
    }

    Future<void> removePlayer(String playerId) async {
        final current = state.value;
        if (current == null) return;

        final removePlayer = ref.read(removePlayerUseCaseProvider);
        await _update(removePlayer.execute(game: current, playerId: playerId));
    }

    Future<void> renamePlayer(String playerId, String newName) async {
        final current = state.value;
        if (current == null) return;

        final renamePlayer = ref.read(renamePlayerUseCaseProvider);
        await _update(
            renamePlayer.execute(game: current, playerId: playerId, newName: newName),
        );
    }

    Future<void> removeAllPlayers() async {
        final current = state.value;
        if (current == null) return;

        final removeAllPlayers = ref.read(removeAllPlayersUseCaseProvider);
        await _update(removeAllPlayers.execute(game: current));
    }

    Future<void> reorderPlayers(List<Player> players) async {
        final current = state.value;
        if (current == null) return;

        final reorderPlayers = ref.read(reorderPlayersUseCaseProvider);
        await _update(reorderPlayers.execute(game: current, players: players));
    }

    Future<void> addRound() async {
        final current = state.value;
        if (current == null) return;

        final createRound = ref.read(createRoundUseCaseProvider);
        await _update(createRound.execute(game: current));
    }

    Future<void> recordScore({
        required int roundNumber,
        required String playerId,
        required int score,
    }) async {
        final current = state.value;
        if (current == null) return;

        final recordRoundScore = ref.read(recordRoundScoreUseCaseProvider);
        await _update(
            recordRoundScore.execute(
                game: current,
                roundNumber: roundNumber,
                playerId: playerId,
                score: score,
            ),
        );
    }

    Future<void> resetGame() async {
        final current = state.value;
        if (current == null) return;

        final resetGame = ref.read(resetGameUseCaseProvider);
        await _update(resetGame.execute(game: current));
    }

    Future<void> updateSettings({
        GameMode? mode,
        int? targetScore,
        PlayerSortMode? sortMode,
    }) async {
        final current = state.value;
        if (current == null) return;

        final updateGameSettings = ref.read(updateGameSettingsUseCaseProvider);
        await _update(
            updateGameSettings.execute(
                game: current,
                mode: mode,
                targetScore: targetScore,
                sortMode: sortMode,
            ),
        );
    }

    Future<void> _update(Game game) async {
        state = AsyncData(game);
        await ref.read(saveGameUseCaseProvider).execute(game);
    }
}

final activeGameProvider = AsyncNotifierProvider<ActiveGameNotifier, Game?>(
    ActiveGameNotifier.new,
);
