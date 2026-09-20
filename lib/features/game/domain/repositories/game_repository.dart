import '../entities/game.dart';

abstract class GameRepository {
    Future<void> saveGame(Game game);

    Future<Game?> loadGame();

    Future<void> clearGame();
}
