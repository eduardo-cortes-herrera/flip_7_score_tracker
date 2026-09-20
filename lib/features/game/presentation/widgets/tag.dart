import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
    final String label;
    final Color? backgroundColor;
    final Color? textColor;

    const Tag({
        super.key,
        required this.label,
        this.backgroundColor,
        this.textColor,
    });

    @override
    Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: backgroundColor ?? colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? colorScheme.onPrimary,
                ),
            ),
        );
    }
}
