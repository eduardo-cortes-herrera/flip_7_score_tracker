import 'package:hive/hive.dart';

import '../../domain/entities/player.dart';

part 'player_model.g.dart';

@HiveType(typeId: 1)
class PlayerModel {
    @HiveField(0)
    final String id;

    @HiveField(1)
    final String name;

    const PlayerModel({
        required this.id,
        required this.name,
    });

    factory PlayerModel.fromEntity(Player player) {
        return PlayerModel(
            id: player.id,
            name: player.name,
        );
    }

    Player toEntity() {
        return Player(
            id: id,
            name: name,
        );
    }
}
