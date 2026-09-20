class PlayerRound {
    final String playerId;
    final int? score;

    const PlayerRound({
        required this.playerId,
        this.score,
    });

    PlayerRound copyWith({
        String? playerId,
        int? score,
    }) {
        return PlayerRound(
            playerId: playerId ?? this.playerId,
            score: score ?? this.score,
        );
    }
}