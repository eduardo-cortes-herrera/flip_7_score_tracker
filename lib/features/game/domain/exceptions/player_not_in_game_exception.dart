class PlayerNotInGameException implements Exception {
    final String message;

    const PlayerNotInGameException(this.message);
}
