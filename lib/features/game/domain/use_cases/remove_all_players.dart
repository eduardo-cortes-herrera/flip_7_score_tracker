import '../entities/game.dart';

class RemoveAllPlayers {
    Game execute({
        required Game game,
    }) {
        return game.copyWith(players: const [], rounds: const []);
    }
}
