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

    final Color bgColor = ok
        ? (isEntrada ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE))
        : const Color(0xFFFEE2E2);

    final Color borderColor = ok
        ? (isEntrada ? const Color(0xFF16A34A) : const Color(0xFF0284C7))
        : const Color(0xFFDC2626);

    final Color titleColor = ok
        ? (isEntrada ? const Color(0xFF14532D) : const Color(0xFF075985))
        : const Color(0xFF7F1D1D);

    final IconData icon = ok
        ? (isEntrada ? Icons.check_circle_rounded : Icons.exit_to_app_rounded)
        : Icons.cancel_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: borderColor, size: 28),
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
                        color: borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.tipo.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${result.fechaHora.hour.toString().padLeft(2, '0')}:${result.fechaHora.minute.toString().padLeft(2, '0')}:${result.fechaHora.second.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: titleColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  result.mensaje,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                Text(
                  result.nombreSocio,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyBlueDark,
                  ),
                ),
                if (result.detalle != null && result.detalle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      result.detalle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: titleColor.withValues(alpha: 0.8),
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
              icon: Icon(Icons.close_rounded, size: 18, color: titleColor),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
