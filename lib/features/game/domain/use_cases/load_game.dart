import '../entities/game.dart';
import '../repositories/game_repository.dart';

class LoadGame {
    final GameRepository repository;

    const LoadGame(this.repository);

    Future<Game?> execute() => repository.loadGame();
}
