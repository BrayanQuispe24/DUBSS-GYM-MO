import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/validacion_acceso_model.dart';

class ResultadoAccesoDialog extends StatelessWidget {
  final ValidacionAccesoModel validacion;
  final VoidCallback onDismiss;

  const ResultadoAccesoDialog({
    super.key,
    required this.validacion,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context,
    ValidacionAccesoModel validacion, {
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResultadoAccesoDialog(
        validacion: validacion,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ok = validacion.permitido;
    final color = ok ? AppColors.successEmerald : AppColors.accentVibrant;
    final bgColor = ok
        ? AppColors.successEmerald.withValues(alpha: 0.15)
        : AppColors.primaryCrimson.withValues(alpha: 0.15);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      backgroundColor: AppColors.carbonSurface,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon Container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
              ),
              child: Icon(
                ok ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 44,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              ok ? '¡ACCESO PERMITIDO!' : '¡ACCESO DENEGADO!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Message
            Text(
              validacion.mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSlateLight,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // User & Admission details if permitted
            if (ok && validacion.usuarioNombre != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.carbonSurfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      validacion.usuarioNombre!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (validacion.usuarioRu != null)
                      Text(
                        'R.U.: ${validacion.usuarioRu}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                      ),
                    if (validacion.disciplina != null)
                      Text(
                        'Disciplina: ${validacion.disciplina}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.solarGold,
                        ),
                      ),
                    Text(
                      'Tipo de Registro: ${validacion.tipo.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (!ok && validacion.motivo != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Causa: ${validacion.motivo}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentVibrant,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Close / Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ok ? AppColors.successEmerald : AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text(
                  'Continuar Escaneando',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
