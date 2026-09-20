class NoPlayersInGameException implements Exception {
    final String message;

    const NoPlayersInGameException(this.message);
}
