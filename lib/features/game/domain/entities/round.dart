import 'player_round.dart';

class Round {
    final int number;
    final List<PlayerRound> playerRounds;

    const Round({
        required this.number,
        required this.playerRounds,
    });

    Round copyWith({
        int? number,
        List<PlayerRound>? playerRounds,
    }) {
        return Round(
            number: number ?? this.number,
            playerRounds: playerRounds ?? this.playerRounds,
        );
    }

    /// The score for [playerId] in this round, or null if they haven't
    /// scored yet, or if this round predates the player joining the game.
    int? scoreForPlayer(String playerId) {
        for (final playerRound in playerRounds) {
            if (playerRound.playerId == playerId) return playerRound.score;
        }
        return null;
    }
}
