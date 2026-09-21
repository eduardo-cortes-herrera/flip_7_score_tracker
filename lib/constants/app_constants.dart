import '../features/game/domain/entities/game_mode.dart';

/// App identity, contact/support links, and default game/theme settings
/// gathered in one place so they can be edited without hunting through the
/// UI layer.

const String appName = 'Flip 7 Score Tracker';
const String packageId = 'com.eduardocortes.flip7scoretracker';
const String feedbackEmail = 'echo.congrats636@passinbox.com';
const String buyMeACoffeeUrl = 'https://ko-fi.com/eduardo_cortes_herrera';

const int defaultTargetScore = 200;
const GameMode defaultGameMode = GameMode.classic;
const String defaultThemeId = 'system';
