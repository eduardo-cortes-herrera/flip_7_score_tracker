import 'package:hive/hive.dart';

import '../../domain/entities/player_round.dart';

part 'player_round_model.g.dart';

@HiveType(typeId: 2)
class PlayerRoundModel {
    @HiveField(0)
    final String playerId;

    @HiveField(1)
    final int? score;

    const PlayerRoundModel({
        required this.playerId,
        this.score,
    });

    factory PlayerRoundModel.fromEntity(PlayerRound playerRound) {
        return PlayerRoundModel(
            playerId: playerRound.playerId,
            score: playerRound.score,
        );
    }

    PlayerRound toEntity() {
        return PlayerRound(
            playerId: playerId,
            score: score,
        );
    }
}
