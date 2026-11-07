import 'package:flutter/material.dart';

class KpiMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color accentColor;
  final String? deltaText;
  final bool? isDeltaPositive; // null: neutro, true: favorable (verde o según contexto), false: desfavor

  const KpiMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    this.accentColor = const Color(0xFFF59E0B),
    this.deltaText,
    this.isDeltaPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              if (deltaText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDeltaBgColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDeltaIcon(),
                        size: 12,
                        color: _getDeltaTextColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deltaText!,
                        style: TextStyle(
                          color: _getDeltaTextColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getDeltaBgColor() {
    if (isDeltaPositive == null) return Colors.white10;
    return isDeltaPositive! ? const Color(0xFF10B981).withAlpha(40) : const Color(0xFFEF4444).withAlpha(40);
  }

  Color _getDeltaTextColor() {
    if (isDeltaPositive == null) return Colors.white70;
    return isDeltaPositive! ? const Color(0xFF10B981) : const Color(0xFFEF4444);
  }

  IconData _getDeltaIcon() {
    if (isDeltaPositive == null) return Icons.horizontal_rule_rounded;
    return isDeltaPositive! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
  }
}
