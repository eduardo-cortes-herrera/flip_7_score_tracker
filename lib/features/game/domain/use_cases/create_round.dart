import '../entities/game.dart';
import '../entities/player_round.dart';
import '../entities/round.dart';
import '../exceptions/no_players_in_game_exception.dart';

class CreateRound {
    Game execute({
        required Game game,
    }) {
        if (game.players.isEmpty) {
            throw const NoPlayersInGameException(
                'Cannot start a round without players.',
            );
        }

        final round = Round(
            number: game.rounds.length + 1,
            playerRounds: game.players
                .map((player) => PlayerRound(playerId: player.id))
                .toList(),
        );

        return game.copyWith(
            rounds: [
                ...game.rounds,
                round,
            ],
        );
    }
}
