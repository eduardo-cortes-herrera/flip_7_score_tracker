import '../entities/game.dart';

class ResetGame {
    Game execute({
        required Game game,
    }) {
        return game.copyWith(rounds: const []);
    }
}
