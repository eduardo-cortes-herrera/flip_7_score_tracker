import '../entities/game.dart';
import '../entities/player_round.dart';
import '../exceptions/invalid_score_exception.dart';
import '../exceptions/player_not_in_game_exception.dart';
import '../exceptions/round_not_found_exception.dart';

class RecordRoundScore {
    Game execute({
        required Game game,
        required int roundNumber,
        required String playerId,
        required int score,
    }) {
        if (score < 0) {
            throw const InvalidScoreException(
                'Score cannot be negative.',
            );
        }

        if (!game.players.any((player) => player.id == playerId)) {
            throw const PlayerNotInGameException(
                'Player is not part of the game.',
            );
        }

        final roundIndex = game.rounds.indexWhere(
            (round) => round.number == roundNumber,
        );
        if (roundIndex == -1) {
            throw RoundNotFoundException(
                'Round $roundNumber does not exist in this game.',
            );
        }

        final round = game.rounds[roundIndex];
        final playerRoundIndex = round.playerRounds.indexWhere(
            (playerRound) => playerRound.playerId == playerId,
        );

        final updatedPlayerRounds = [...round.playerRounds];
        if (playerRoundIndex == -1) {
            // This round predates the player joining the game (e.g. old data
            // saved before players backfilled new rounds). Add their entry
            // instead of failing.
            updatedPlayerRounds.add(PlayerRound(playerId: playerId, score: score));
        } else {
            updatedPlayerRounds[playerRoundIndex] =
                updatedPlayerRounds[playerRoundIndex].copyWith(score: score);
        }

        final updatedRounds = [...game.rounds];
        updatedRounds[roundIndex] = round.copyWith(
            playerRounds: updatedPlayerRounds,
        );

        return game.copyWith(rounds: updatedRounds);
    }
}
