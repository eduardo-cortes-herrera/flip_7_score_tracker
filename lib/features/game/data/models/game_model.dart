import 'package:hive/hive.dart';

import '../../domain/entities/game.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player_sort_mode.dart';
import 'player_model.dart';
import 'round_model.dart';

part 'game_model.g.dart';

@HiveType(typeId: 4)
class GameModel {
    @HiveField(0)
    final int targetScore;

    @HiveField(1)
    final String mode;

    @HiveField(2)
    final List<PlayerModel> players;

    @HiveField(3)
    final List<RoundModel> rounds;

    @HiveField(4)
    final String? sortMode;

    const GameModel({
        required this.targetScore,
        required this.mode,
        required this.players,
        required this.rounds,
        this.sortMode,
    });

    factory GameModel.fromEntity(Game game) {
        return GameModel(
            targetScore: game.targetScore,
            mode: game.mode.name,
            players:
                game.players.map((player) => PlayerModel.fromEntity(player)).toList(),
            rounds:
                game.rounds.map((round) => RoundModel.fromEntity(round)).toList(),
            sortMode: game.sortMode.name,
        );
    }

    Game toEntity() {
        return Game(
            targetScore: targetScore,
            mode: GameMode.values.byName(mode),
            players: players.map((player) => player.toEntity()).toList(),
            rounds: rounds.map((round) => round.toEntity()).toList(),
            sortMode: sortMode != null
                ? PlayerSortMode.values.byName(sortMode!)
                : PlayerSortMode.listOrder,
        );
    }
}
