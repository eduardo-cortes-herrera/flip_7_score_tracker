import '../entities/game.dart';
import '../exceptions/player_not_in_game_exception.dart';

class RemovePlayer {
    Game execute({
        required Game game,
        required String playerId,
    }) {
        if (!game.players.any((player) => player.id == playerId)) {
            throw const PlayerNotInGameException(
                'Player is not part of the game.',
            );
        }

        return game.copyWith(
            players: game.players
                .where((player) => player.id != playerId)
                .toList(),
            rounds: game.rounds
                .map(
                    (round) => round.copyWith(
                        playerRounds: round.playerRounds
                            .where((playerRound) => playerRound.playerId != playerId)
                            .toList(),
                    ),
                )
                .toList(),
        );
    }
}
