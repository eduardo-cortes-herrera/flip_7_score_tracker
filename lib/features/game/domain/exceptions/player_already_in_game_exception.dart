class PlayerAlreadyInGameException implements Exception {
    final String message;

    const PlayerAlreadyInGameException(this.message);
}
