import 'package:hive_flutter/hive_flutter.dart';

import 'models/game_model.dart';
import 'models/player_model.dart';
import 'models/player_round_model.dart';
import 'models/round_model.dart';

void registerGameHiveAdapters() {
    if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PlayerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PlayerRoundModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(RoundModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(GameModelAdapter());
    }
}
