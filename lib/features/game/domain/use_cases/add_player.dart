import '../entities/game.dart';
import '../entities/player.dart';
import '../entities/player_round.dart';
import '../exceptions/player_already_in_game_exception.dart';

class AddPlayer {
    Game execute({
        required Game game,
        required Player player,
    }) {
        if (game.players.any((p) => p.id == player.id)) {
            throw const PlayerAlreadyInGameException(
                'Player is already part of the game.',
            );
        }

        return game.copyWith(
            players: [
                ...game.players,
                player,
            ],
            rounds: [
                for (final round in game.rounds)
                    round.copyWith(
                        playerRounds: [
                            ...round.playerRounds,
                            PlayerRound(playerId: player.id),
                        ],
                    ),
            ],
        );
    }
}
