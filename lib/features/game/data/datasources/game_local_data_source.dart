import 'package:hive/hive.dart';

import '../models/game_model.dart';

abstract class GameLocalDataSource {
    Future<void> saveGame(GameModel game);

    Future<GameModel?> loadGame();

    Future<void> clearGame();
}

class HiveGameLocalDataSource implements GameLocalDataSource {
    static const String boxName = 'active_game';
    static const String gameKey = 'current';

    Future<Box<GameModel>> _openBox() => Hive.openBox<GameModel>(boxName);

    @override
    Future<void> saveGame(GameModel game) async {
        final box = await _openBox();
        await box.put(gameKey, game);
    }

    @override
    Future<GameModel?> loadGame() async {
        final box = await _openBox();
        return box.get(gameKey);
    }

    @override
    Future<void> clearGame() async {
        final box = await _openBox();
        await box.delete(gameKey);
    }
}
