import 'game_mode.dart';
import 'player.dart';
import 'player_sort_mode.dart';
import 'round.dart';

class Game {
    final int targetScore;
    final GameMode mode;
    final List<Player> players;
    final List<Round> rounds;
    final PlayerSortMode sortMode;

    const Game({
        required this.targetScore,
        required this.mode,
        required this.players,
        required this.rounds,
        this.sortMode = PlayerSortMode.listOrder,
    });

    Game copyWith({
        int? targetScore,
        GameMode? mode,
        List<Player>? players,
        List<Round>? rounds,
        PlayerSortMode? sortMode,
    }) {
        return Game(
            targetScore: targetScore ?? this.targetScore,
            mode: mode ?? this.mode,
            players: players ?? this.players,
            rounds: rounds ?? this.rounds,
            sortMode: sortMode ?? this.sortMode,
        );
    }

    Map<String, int> get totalScores {
        final totals = <String, int>{
            for (final player in players) player.id: 0,
        };

        for (final round in rounds) {
            for (final playerRound in round.playerRounds) {
                totals[playerRound.playerId] =
                    (totals[playerRound.playerId] ?? 0) + (playerRound.score ?? 0);
            }
        }

        return totals;
    }

    int totalScoreForPlayer(String playerId) => totalScores[playerId] ?? 0;

    /// [players] ordered according to [sortMode]: either the order they were
    /// added/reordered in, or descending by total score.
    List<Player> get orderedPlayers {
        if (sortMode == PlayerSortMode.listOrder) return players;

        final sorted = [...players];
        sorted.sort(
            (a, b) => totalScoreForPlayer(b.id).compareTo(totalScoreForPlayer(a.id)),
        );
        return sorted;
    }

    bool get hasPlayerReachedTargetScore =>
        totalScores.values.any((score) => score >= targetScore);

    Player? get winner {
        if (!hasPlayerReachedTargetScore) return null;

        final leadingEntry = totalScores.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
        );

        return players.firstWhere((player) => player.id == leadingEntry.key);
    }

    /// The player currently in first place, regardless of whether the target
    /// score has been reached. Returns null before any round has been played,
    /// or when there is a tie for the highest score.
    Player? get leader {
        if (rounds.isEmpty) return null;

        final totals = totalScores;
        if (totals.isEmpty) return null;

        final maxScore = totals.values.reduce((a, b) => a > b ? a : b);
        if (maxScore <= 0) return null;

        final leaders = totals.entries.where((entry) => entry.value == maxScore);
        if (leaders.length != 1) return null;

        return players.firstWhere((player) => player.id == leaders.first.key);
    }
}
