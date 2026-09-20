import '../entities/game.dart';
import '../entities/game_mode.dart';

class CreateGame {
    Game execute({
        required GameMode mode,
        required int targetScore,
    }) {
        return Game(
            mode: mode,
            targetScore: targetScore,
            players: const [],
            rounds: const [],
        );
    }
}
