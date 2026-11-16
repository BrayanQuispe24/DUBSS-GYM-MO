import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/accesos_provider.dart';

class ResultadoAccesoBanner extends StatelessWidget {
  final AccesoScanResult result;
  final VoidCallback? onDismiss;

  const ResultadoAccesoBanner({
    super.key,
    required this.result,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool ok = result.permitido;
    final bool isEntrada = result.tipo == 'entrada';

    final Color statusColor = ok ? AppColors.successEmerald : AppColors.accentVibrant;
    final Color statusBg = ok
        ? AppColors.successEmerald.withValues(alpha: 0.12)
        : AppColors.accentVibrant.withValues(alpha: 0.12);

    final IconData icon = ok
        ? (isEntrada ? Icons.check_circle_outline : Icons.logout)
        : Icons.cancel_outlined;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.tipo.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${result.fechaHora.hour.toString().padLeft(2, '0')}:${result.fechaHora.minute.toString().padLeft(2, '0')}:${result.fechaHora.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.solarGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.mensaje,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.nombreSocio,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                if (result.detalle != null && result.detalle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      result.detalle!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSlateLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.close, size: 18, color: AppColors.textSlateMuted),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
