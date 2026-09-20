import '../entities/game.dart';
import '../entities/game_mode.dart';
import '../entities/player_sort_mode.dart';

class UpdateGameSettings {
    Game execute({
        required Game game,
        GameMode? mode,
        int? targetScore,
        PlayerSortMode? sortMode,
    }) {
        return game.copyWith(
            mode: mode,
            targetScore: targetScore,
            sortMode: sortMode,
        );
    }
}
