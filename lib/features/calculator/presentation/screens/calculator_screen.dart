import 'package:flutter/material.dart';

import '../../../game/domain/entities/game_mode.dart';
import '../../../game/presentation/widgets/tag.dart';
import '../../domain/calculator_config.dart';
import '../widgets/calculator_toggle_tile.dart';

enum _CalculatorTab { manual, cards }

class CalculatorScreen extends StatefulWidget {
    final GameMode mode;
    final String playerName;
    final int roundNumber;
    final int? initialScore;

    const CalculatorScreen({
        super.key,
        required this.mode,
        required this.playerName,
        required this.roundNumber,
        this.initialScore,
    });

    @override
    State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
    _CalculatorTab _tab = _CalculatorTab.cards;
    final Set<int> _selectedCardIds = {};
    final Set<CalculatorModifier> _selectedModifiers = {};
    late final TextEditingController _manualController;

    @override
    void initState() {
        super.initState();
        _manualController = TextEditingController(
            text: widget.initialScore?.toString() ?? '',
        );
    }

    @override
    void dispose() {
        _manualController.dispose();
        super.dispose();
    }

    CalculatorConfig get _config => calculatorConfigForMode(widget.mode);

    bool get _isFlipSeven => isFlipSeven(_selectedCardIds, _config);

    int get _cardsTotal => calculateCardsScore(
        selectedCardIds: _selectedCardIds,
        selectedModifiers: _selectedModifiers,
        config: _config,
    );

    int get _total {
        if (_tab == _CalculatorTab.manual) {
            return int.tryParse(_manualController.text) ?? 0;
        }
        return _cardsTotal;
    }

    void _confirm() {
        Navigator.of(context).pop(_total);
    }

    void _resetCalculator() {
        setState(() {
            _selectedCardIds.clear();
            _selectedModifiers.clear();
            _manualController.clear();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('${widget.playerName} · Round ${widget.roundNumber}'),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset',
                        onPressed: _resetCalculator,
                    ),
                ],
            ),
            body: SafeArea(
                child: Column(
                    children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: SegmentedButton<_CalculatorTab>(
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    selectedForegroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                ),
                                segments: const [
                                    ButtonSegment(
                                        value: _CalculatorTab.manual,
                                        label: Text('Manual'),
                                    ),
                                    ButtonSegment(
                                        value: _CalculatorTab.cards,
                                        label: Text('Cards'),
                                    ),
                                ],
                                selected: {_tab},
                                onSelectionChanged: (selection) {
                                    setState(() => _tab = selection.first);
                                },
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                                children: [
                                    AnimatedBuilder(
                                        animation: _manualController,
                                        builder: (context, _) => Text(
                                            '$_total',
                                            style: Theme.of(context).textTheme.displayMedium,
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                        height: 24,
                                        child: Center(
                                            child: Visibility(
                                                visible: _tab == _CalculatorTab.cards &&
                                                    _isFlipSeven,
                                                maintainSize: true,
                                                maintainAnimation: true,
                                                maintainState: true,
                                                child: Tag(
                                                    label:
                                                        'Flip 7! +${_config.flipSevenBonus}',
                                                ),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Expanded(
                            child: _tab == _CalculatorTab.cards
                                ? _CardsMode(
                                    config: _config,
                                    selectedCardIds: _selectedCardIds,
                                    selectedModifiers: _selectedModifiers,
                                    onChanged: () => setState(() {}),
                                )
                                : _ManualMode(controller: _manualController),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: AnimatedBuilder(
                                    animation: _manualController,
                                    builder: (context, _) => FilledButton(
                                        onPressed: _confirm,
                                        child: Text('Confirm ($_total)'),
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _CardsMode extends StatelessWidget {
    final CalculatorConfig config;
    final Set<int> selectedCardIds;
    final Set<CalculatorModifier> selectedModifiers;
    final VoidCallback onChanged;

    const _CardsMode({
        required this.config,
        required this.selectedCardIds,
        required this.selectedModifiers,
        required this.onChanged,
    });

    static const double _numberAspectRatio = 1.6;

    Set<int> get _selectedValues => config.numberCards
        .where((card) => selectedCardIds.contains(card.id))
        .map((card) => card.value)
        .toSet();

    bool _blocksNewValue(int value) =>
        !_selectedValues.contains(value) &&
        _selectedValues.length >= config.flipSevenCount;

    void _toggleNumber(CalculatorNumberCard card) {
        if (!selectedCardIds.remove(card.id)) {
            if (_blocksNewValue(card.value)) return;
            selectedCardIds.add(card.id);
        }
        onChanged();
    }

    @override
    Widget build(BuildContext context) {
        final zeroCard = config.zeroCard;

        return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
                GridView.count(
                    crossAxisCount: config.numberCardsColumns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: _numberAspectRatio,
                    children: [
                        for (final card in config.gridNumberCards)
                            CalculatorToggleTile(
                                label: '${card.value}',
                                selected: selectedCardIds.contains(card.id),
                                enabled: selectedCardIds.contains(card.id) ||
                                    !_blocksNewValue(card.value),
                                onTap: () => _toggleNumber(card),
                            ),
                    ],
                ),
                if (zeroCard != null) ...[
                    const SizedBox(height: 8),
                    LayoutBuilder(
                        builder: (context, constraints) {
                            const spacing = 8.0;
                            final cellWidth = (constraints.maxWidth -
                                    spacing * (config.numberCardsColumns - 1)) /
                                config.numberCardsColumns;
                            return Center(
                                child: SizedBox(
                                    width: cellWidth,
                                    height: cellWidth / _numberAspectRatio,
                                    child: CalculatorToggleTile(
                                        label: '0',
                                        selected: selectedCardIds.contains(zeroCard.id),
                                        enabled: selectedCardIds.contains(zeroCard.id) ||
                                            !_blocksNewValue(0),
                                        onTap: () => _toggleNumber(zeroCard),
                                    ),
                                ),
                            );
                        },
                    ),
                ],
                const SizedBox(height: 16),
                GridView.count(
                    crossAxisCount: config.modifierColumns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                    children: [
                        for (final modifier in config.modifiers)
                            CalculatorToggleTile(
                                label: modifier.label,
                                selected: selectedModifiers.contains(modifier),
                                enabled: true,
                                onTap: () {
                                    if (!selectedModifiers.add(modifier)) {
                                        selectedModifiers.remove(modifier);
                                    }
                                    onChanged();
                                },
                            ),
                    ],
                ),
                const SizedBox(height: 16),
            ],
        );
    }
}

class _ManualMode extends StatelessWidget {
    final TextEditingController controller;

    const _ManualMode({required this.controller});

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: 'Score'),
            ),
        );
    }
}
