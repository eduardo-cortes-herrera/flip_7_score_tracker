import '../entities/game.dart';
import '../repositories/game_repository.dart';

class SaveGame {
    final GameRepository repository;

    const SaveGame(this.repository);

    Future<void> execute(Game game) => repository.saveGame(game);
}
