import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_data_source.dart';
import '../models/game_model.dart';

class GameRepositoryImpl implements GameRepository {
    final GameLocalDataSource localDataSource;

    const GameRepositoryImpl(this.localDataSource);

    @override
    Future<void> saveGame(Game game) {
        return localDataSource.saveGame(GameModel.fromEntity(game));
    }

    @override
    Future<Game?> loadGame() async {
        final model = await localDataSource.loadGame();
        return model?.toEntity();
    }

    @override
    Future<void> clearGame() {
        return localDataSource.clearGame();
    }
}
