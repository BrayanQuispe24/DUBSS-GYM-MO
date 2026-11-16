import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/boleta_inscripcion_model.dart';
import '../screens/visor_pdf_screen.dart';
import 'pdf_boleta_inscripcion_builder.dart';
import 'qr_pase_modal.dart';

class BoletaInscripcionCard extends StatelessWidget {
  final BoletaInscripcionModel boleta;

  const BoletaInscripcionCard({
    super.key,
    required this.boleta,
  });

  @override
  Widget build(BuildContext context) {
    final isActiva = boleta.isActiva;
    final statusColor = isActiva ? AppColors.successEmerald : AppColors.accentVibrant;
    final statusBg = isActiva
        ? AppColors.successEmerald.withValues(alpha: 0.15)
        : AppColors.accentVibrant.withValues(alpha: 0.15);
    final statusBorder = isActiva ? AppColors.successEmerald : AppColors.accentVibrant;

    final fInicioStr = boleta.fechaInicio != null
        ? '${boleta.fechaInicio!.day.toString().padLeft(2, '0')}/${boleta.fechaInicio!.month.toString().padLeft(2, '0')}/${boleta.fechaInicio!.year}'
        : '-';

    final fFinStr = boleta.fechaFin != null
        ? '${boleta.fechaFin!.day.toString().padLeft(2, '0')}/${boleta.fechaFin!.month.toString().padLeft(2, '0')}/${boleta.fechaFin!.year}'
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3.0, color: statusColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discipline + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          boleta.disciplina,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBorder, width: 0.8),
                        ),
                        child: Text(
                          isActiva ? 'HABILITADO' : 'EXPIRADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Code
                  Text(
                    'Inscripción: ${boleta.numeroBoleta}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.solarGold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Vigencia & Horario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12, color: AppColors.textSlateMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Vigencia: $fInicioStr al $fFinStr',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSlateLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 12, color: AppColors.textSlateMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Turno: ${boleta.horarioFormateado}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSlateLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isActiva)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${boleta.diasRestantes} días rest.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentVibrant,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Divider(color: AppColors.borderSubtle, height: 20),

                  // Action Buttons: Pase QR & Ver Boleta PDF
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Ver PDF
                      OutlinedButton.icon(
                        onPressed: () {
                          VisorPdfScreen.open(
                            context,
                            title: 'Inscripción ${boleta.numeroBoleta}',
                            documentBuilder: () => PdfBoletaInscripcionBuilder.buildPdf(boleta),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 15, color: AppColors.textSlateLight),
                        label: const Text('Boleta PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSlateLight,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Generar / Mostrar Pase QR
                      FilledButton.icon(
                        onPressed: () {
                          QRPaseModal.show(context, boleta);
                        },
                        icon: const Icon(Icons.qr_code, size: 16, color: Colors.white),
                        label: const Text('Pase QR'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryCrimson,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
