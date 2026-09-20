import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/game_local_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/use_cases/add_player.dart';
import '../../domain/use_cases/create_game.dart';
import '../../domain/use_cases/create_round.dart';
import '../../domain/use_cases/load_game.dart';
import '../../domain/use_cases/record_round_score.dart';
import '../../domain/use_cases/remove_all_players.dart';
import '../../domain/use_cases/remove_player.dart';
import '../../domain/use_cases/rename_player.dart';
import '../../domain/use_cases/reorder_players.dart';
import '../../domain/use_cases/reset_game.dart';
import '../../domain/use_cases/save_game.dart';
import '../../domain/use_cases/update_game_settings.dart';

final gameLocalDataSourceProvider = Provider<GameLocalDataSource>((ref) {
    return HiveGameLocalDataSource();
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
    return GameRepositoryImpl(ref.watch(gameLocalDataSourceProvider));
});

final createGameUseCaseProvider = Provider((ref) => CreateGame());

final addPlayerUseCaseProvider = Provider((ref) => AddPlayer());

final removePlayerUseCaseProvider = Provider((ref) => RemovePlayer());

final renamePlayerUseCaseProvider = Provider((ref) => RenamePlayer());

final removeAllPlayersUseCaseProvider = Provider((ref) => RemoveAllPlayers());

final reorderPlayersUseCaseProvider = Provider((ref) => ReorderPlayers());

final createRoundUseCaseProvider = Provider((ref) => CreateRound());

final recordRoundScoreUseCaseProvider = Provider((ref) => RecordRoundScore());

final resetGameUseCaseProvider = Provider((ref) => ResetGame());

final updateGameSettingsUseCaseProvider = Provider((ref) => UpdateGameSettings());

final saveGameUseCaseProvider = Provider((ref) {
    return SaveGame(ref.watch(gameRepositoryProvider));
});

final loadGameUseCaseProvider = Provider((ref) {
    return LoadGame(ref.watch(gameRepositoryProvider));
});
