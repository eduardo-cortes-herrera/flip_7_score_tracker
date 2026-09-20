import '../entities/game.dart';
import '../entities/player.dart';
import '../exceptions/invalid_player_order_exception.dart';

class ReorderPlayers {
    Game execute({
        required Game game,
        required List<Player> players,
    }) {
        final currentIds = game.players.map((player) => player.id).toSet();
        final newIds = players.map((player) => player.id).toSet();

        if (currentIds.length != players.length || currentIds.difference(newIds).isNotEmpty) {
            throw const InvalidPlayerOrderException(
                'Reordered players must be the same set as the current players.',
            );
        }

        return game.copyWith(players: players);
    }
}
