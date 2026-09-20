import 'package:hive/hive.dart';

import '../../domain/entities/round.dart';
import 'player_round_model.dart';

part 'round_model.g.dart';

@HiveType(typeId: 3)
class RoundModel {
    @HiveField(0)
    final int number;

    @HiveField(1)
    final List<PlayerRoundModel> playerRounds;

    const RoundModel({
        required this.number,
        required this.playerRounds,
    });

    factory RoundModel.fromEntity(Round round) {
        return RoundModel(
            number: round.number,
            playerRounds: round.playerRounds
                .map((playerRound) => PlayerRoundModel.fromEntity(playerRound))
                .toList(),
        );
    }

    Round toEntity() {
        return Round(
            number: number,
            playerRounds:
                playerRounds.map((playerRound) => playerRound.toEntity()).toList(),
        );
    }
}
