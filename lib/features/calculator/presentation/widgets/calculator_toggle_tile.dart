import 'package:flutter/material.dart';

class CalculatorToggleTile extends StatelessWidget {
    final String label;
    final bool selected;
    final bool enabled;
    final VoidCallback? onTap;

    const CalculatorToggleTile({
        super.key,
        required this.label,
        required this.selected,
        this.enabled = true,
        this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        final Color background;
        final Color foreground;
        final double elevation;
        final Color shadowColor;
        if (selected) {
            background = colorScheme.primary;
            foreground = colorScheme.onPrimary;
            elevation = 4;
            shadowColor = colorScheme.primary;
        } else if (!enabled) {
            background = colorScheme.surfaceContainerLow;
            foreground = colorScheme.onSurface.withValues(alpha: 0.38);
            elevation = 0;
            shadowColor = colorScheme.shadow;
        } else {
            background = colorScheme.surfaceContainerHigh;
            foreground = colorScheme.onSurface;
            elevation = 2;
            shadowColor = colorScheme.shadow;
        }

        return Material(
            color: background,
            elevation: elevation,
            shadowColor: shadowColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: enabled ? onTap : null,
                child: Center(
                    child: Text(
                        label,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                        ),
                    ),
                ),
            ),
        );
    }
}
