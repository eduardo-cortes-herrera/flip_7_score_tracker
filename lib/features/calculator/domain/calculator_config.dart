import '../../game/domain/entities/game_mode.dart';

class CalculatorNumberCard {
    final int value;
    final int id;

    const CalculatorNumberCard(this.value, this.id);
}

class CalculatorModifier {
    final String label;
    final int? addValue;
    final bool isMultiplier;
    final bool isDivider;

    const CalculatorModifier.additive(int value)
        : addValue = value,
          isMultiplier = false,
          isDivider = false,
          label = value >= 0 ? '+$value' : '$value';

    const CalculatorModifier.multiplier(this.label)
        : addValue = null,
          isMultiplier = true,
          isDivider = false;

    const CalculatorModifier.divider(this.label)
        : addValue = null,
          isMultiplier = false,
          isDivider = true;

    int get factor => 2;

    int get divisor => 2;
}

class CalculatorConfig {
    /// All number cards for this mode, including the zero card (if any) and
    /// any duplicate-value cards (e.g. two 13s). Each card has a unique [id],
    /// even when two cards share the same [CalculatorNumberCard.value].
    final List<CalculatorNumberCard> numberCards;
    final int numberCardsColumns;

    /// When true, the zero card (if any) is pulled out of the grid and
    /// rendered on its own, centered row below it. When false, zero stays in
    /// its natural position within [numberCards].
    final bool isolateZeroCard;
    final List<CalculatorModifier> modifiers;
    final int modifierColumns;
    final int flipSevenCount;
    final int flipSevenBonus;

    const CalculatorConfig({
        required this.numberCards,
        this.numberCardsColumns = 3,
        this.isolateZeroCard = true,
        required this.modifiers,
        this.modifierColumns = 6,
        this.flipSevenCount = 7,
        this.flipSevenBonus = 15,
    });

    List<CalculatorNumberCard> get gridNumberCards => isolateZeroCard
        ? numberCards.where((card) => card.value != 0).toList()
        : numberCards;

    CalculatorNumberCard? get zeroCard => isolateZeroCard
        ? numberCards.where((card) => card.value == 0).firstOrNull
        : null;
}

List<CalculatorNumberCard> _sequentialCards(List<int> values) {
    return [
        for (var i = 0; i < values.length; i++) CalculatorNumberCard(values[i], i),
    ];
}

final _classicConfig = CalculatorConfig(
    numberCards: _sequentialCards([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
    modifiers: const [
        CalculatorModifier.additive(2),
        CalculatorModifier.additive(4),
        CalculatorModifier.additive(6),
        CalculatorModifier.additive(8),
        CalculatorModifier.additive(10),
        CalculatorModifier.multiplier('x2'),
    ],
);

final _vengeanceConfig = CalculatorConfig(
    numberCards: _sequentialCards(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13, 0],
    ),
    isolateZeroCard: false,
    modifiers: const [
        CalculatorModifier.additive(-2),
        CalculatorModifier.additive(-4),
        CalculatorModifier.additive(-6),
        CalculatorModifier.additive(-8),
        CalculatorModifier.additive(-10),
        CalculatorModifier.divider('/2'),
    ],
);

final _mixedConfig = CalculatorConfig(
    numberCards: _vengeanceConfig.numberCards,
    isolateZeroCard: false,
    modifiers: [
        ..._classicConfig.modifiers,
        ..._vengeanceConfig.modifiers,
    ],
);

CalculatorConfig calculatorConfigForMode(GameMode mode) {
    switch (mode) {
        case GameMode.classic:
            return _classicConfig;
        case GameMode.vengeance:
            return _vengeanceConfig;
        case GameMode.mixed:
            return _mixedConfig;
    }
}

Set<int> _uniqueValuesOf(Set<int> selectedCardIds, CalculatorConfig config) {
    return config.numberCards
        .where((card) => selectedCardIds.contains(card.id))
        .map((card) => card.value)
        .toSet();
}

bool isFlipSeven(Set<int> selectedCardIds, CalculatorConfig config) {
    return _uniqueValuesOf(selectedCardIds, config).length >= config.flipSevenCount;
}

int calculateCardsScore({
    required Set<int> selectedCardIds,
    required Set<CalculatorModifier> selectedModifiers,
    required CalculatorConfig config,
}) {
    final numbersSum = config.numberCards
        .where((card) => selectedCardIds.contains(card.id))
        .fold<int>(0, (sum, card) => sum + card.value);

    final multiplierProduct = selectedModifiers
        .where((modifier) => modifier.isMultiplier)
        .fold<int>(1, (product, modifier) => product * modifier.factor);

    final divisorProduct = selectedModifiers
        .where((modifier) => modifier.isDivider)
        .fold<int>(1, (product, modifier) => product * modifier.divisor);

    final scaledNumbersSum = (numbersSum * multiplierProduct) ~/ divisorProduct;

    final additiveSum = selectedModifiers
        .where((modifier) => !modifier.isMultiplier && !modifier.isDivider)
        .fold<int>(0, (sum, modifier) => sum + (modifier.addValue ?? 0));

    final flipSevenBonus =
        isFlipSeven(selectedCardIds, config) ? config.flipSevenBonus : 0;

    return scaledNumbersSum + additiveSum + flipSevenBonus;
}
