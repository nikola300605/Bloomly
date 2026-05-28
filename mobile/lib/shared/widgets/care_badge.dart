import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Inline care-status badge shown on plant cards and detail screens.
/// kind: "ok" | "warn" | "bad" | "info"
class CareBadge extends StatelessWidget {
  final String kind;
  final String label;
  final double fontSize;

  const CareBadge({
    super.key,
    required this.kind,
    required this.label,
    this.fontSize = 11,
  });

  Color get _color => switch (kind) {
        'bad' => AppColors.danger,
        'warn' => AppColors.warn,
        'info' => AppColors.info,
        _ => AppColors.ok,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: _color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: fontSize,
          color: _color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
