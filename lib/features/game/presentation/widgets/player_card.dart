import 'package:flutter/material.dart';

import '../../domain/entities/player.dart';
import 'tag.dart';

enum _PlayerCardAction { edit, remove }

class PlayerCard extends StatelessWidget {
    final Player player;
    final int totalScore;
    final int targetScore;
    final int roundsPlayed;
    final List<int?> roundScores;
    final bool isLeader;
    final VoidCallback onTap;
    final void Function(int roundNumber, int? currentScore) onEditRoundScore;
    final VoidCallback onEditPlayer;
    final VoidCallback onRemovePlayer;

    const PlayerCard({
        super.key,
        required this.player,
        required this.totalScore,
        required this.targetScore,
        required this.roundsPlayed,
        required this.roundScores,
        required this.isLeader,
        required this.onTap,
        required this.onEditRoundScore,
        required this.onEditPlayer,
        required this.onRemovePlayer,
    });

    @override
    Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final remaining = targetScore - totalScore;

        final baseColor = colorScheme.surfaceContainerLow;
        final fillColor = Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.18),
            baseColor,
        );
        final progress =
            targetScore <= 0 ? 0.0 : (totalScore / targetScore).clamp(0.0, 1.0);

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Material(
                color: Colors.transparent,
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [fillColor, baseColor],
                            stops: [progress, progress],
                        ),
                    ),
                    child: InkWell(
                        onTap: onTap,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Expanded(
                                                child: Row(
                                                    children: [
                                                        if (isLeader) ...[
                                                            const Icon(
                                                                Icons.emoji_events,
                                                                color: Colors.amber,
                                                            ),
                                                            const SizedBox(width: 6),
                                                        ],
                                                        Expanded(
                                                            child: Text(
                                                                player.name,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .headlineMedium,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                                '$totalScore/$targetScore',
                                                style: Theme.of(context).textTheme.headlineMedium,
                                            ),
                                            PopupMenuButton<_PlayerCardAction>(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.more_vert),
                                                onSelected: (action) {
                                                    switch (action) {
                                                        case _PlayerCardAction.edit:
                                                            onEditPlayer();
                                                        case _PlayerCardAction.remove:
                                                            onRemovePlayer();
                                                    }
                                                },
                                                itemBuilder: (context) => const [
                                                    PopupMenuItem(
                                                        value: _PlayerCardAction.edit,
                                                        child: ListTile(
                                                            leading: Icon(Icons.edit_outlined),
                                                            title: Text('Edit'),
                                                        ),
                                                    ),
                                                    PopupMenuItem(
                                                        value: _PlayerCardAction.remove,
                                                        child: ListTile(
                                                            leading: Icon(
                                                                Icons.person_remove_outlined,
                                                            ),
                                                            title: Text('Remove'),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 4),
                                    Tag(
                                        label: remaining > 0
                                            ? '$remaining to go'
                                            : 'Target reached',
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Expanded(
                                                child: roundScores.isEmpty
                                                    ? Text(
                                                        'No rounds yet',
                                                        style: TextStyle(
                                                            color: colorScheme.onSurfaceVariant,
                                                        ),
                                                    )
                                                    : _RoundScoresRow(
                                                        roundScores: roundScores,
                                                        onEditRoundScore: onEditRoundScore,
                                                    ),
                                            ),
                                            const SizedBox(width: 20),
                                            Text(
                                                roundsPlayed == 1
                                                    ? '1 round'
                                                    : '$roundsPlayed rounds',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: colorScheme.onSurfaceVariant,
                                                    ),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}

class _RoundScoresRow extends StatefulWidget {
    final List<int?> roundScores;
    final void Function(int roundNumber, int? currentScore) onEditRoundScore;

    const _RoundScoresRow({
        required this.roundScores,
        required this.onEditRoundScore,
    });

    @override
    State<_RoundScoresRow> createState() => _RoundScoresRowState();
}

class _RoundScoresRowState extends State<_RoundScoresRow> {
    final ScrollController _controller = ScrollController();
    bool _canScrollLeft = false;
    bool _canScrollRight = false;

    @override
    void initState() {
        super.initState();
        _controller.addListener(_updateFadeState);
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeState());
    }

    @override
    void didUpdateWidget(_RoundScoresRow oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.roundScores.length != widget.roundScores.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeState());
        }
    }

    @override
    void dispose() {
        _controller.removeListener(_updateFadeState);
        _controller.dispose();
        super.dispose();
    }

    void _updateFadeState() {
        if (!_controller.hasClients) return;

        final position = _controller.position;
        final canScrollLeft = position.pixels > 0.5;
        final canScrollRight = position.pixels < position.maxScrollExtent - 0.5;

        if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
            setState(() {
                _canScrollLeft = canScrollLeft;
                _canScrollRight = canScrollRight;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SizedBox(
            height: 32,
            child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                    return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                            _canScrollLeft ? Colors.transparent : Colors.black,
                            Colors.black,
                            Colors.black,
                            _canScrollRight ? Colors.transparent : Colors.black,
                        ],
                        stops: const [0.0, 0.08, 0.92, 1.0],
                    ).createShader(bounds);
                },
                child: ListView.separated(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.roundScores.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                        final score = widget.roundScores[index];
                        final scored = score != null;

                        return ActionChip(
                            label: Text(
                                score?.toString() ?? '?',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scored
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                ),
                            ),
                            backgroundColor:
                                scored ? colorScheme.primary : colorScheme.surfaceContainerHigh,
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => widget.onEditRoundScore(index + 1, score),
                        );
                    },
                ),
            ),
        );
    }
}
