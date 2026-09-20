import '../entities/game.dart';
import '../exceptions/invalid_player_name_exception.dart';
import '../exceptions/player_not_in_game_exception.dart';

class RenamePlayer {
    Game execute({
        required Game game,
        required String playerId,
        required String newName,
    }) {
        final trimmedName = newName.trim();
        if (trimmedName.isEmpty) {
            throw const InvalidPlayerNameException(
                'Player name cannot be empty.',
            );
        }

        final playerIndex = game.players.indexWhere(
            (player) => player.id == playerId,
        );
        if (playerIndex == -1) {
            throw const PlayerNotInGameException(
                'Player is not part of the game.',
            );
        }

        final updatedPlayers = [...game.players];
        updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
            name: trimmedName,
        );

        return game.copyWith(players: updatedPlayers);
    }
}
