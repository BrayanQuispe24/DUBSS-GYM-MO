import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/boleta_pago_model.dart';
import '../screens/visor_pdf_screen.dart';
import 'pdf_boleta_pago_builder.dart';

class BoletaPagoCard extends StatelessWidget {
  final BoletaPagoModel boleta;

  const BoletaPagoCard({
    super.key,
    required this.boleta,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = boleta.isPagado;
    final statusColor = isSuccess ? AppColors.successEmerald : AppColors.solarGold;
    final statusBg = isSuccess
        ? AppColors.successEmerald.withValues(alpha: 0.15)
        : AppColors.solarAmber.withValues(alpha: 0.15);
    final statusBorder = isSuccess ? AppColors.successEmerald : AppColors.solarGold;

    final fechaStr = boleta.fechaPago != null
        ? '${boleta.fechaPago!.day.toString().padLeft(2, '0')}/${boleta.fechaPago!.month.toString().padLeft(2, '0')}/${boleta.fechaPago!.year}'
        : 'Sin fecha';

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
            Container(height: 3.0, color: AppColors.primaryCrimson),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_outlined, size: 16, color: AppColors.solarGold),
                          const SizedBox(width: 6),
                          Text(
                            boleta.numeroBoleta,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.solarGold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBorder, width: 0.8),
                        ),
                        child: Text(
                          boleta.estadoLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Concept
                  Text(
                    boleta.concepto,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),

                  if (boleta.planNombre != null && boleta.planNombre!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Plan: ${boleta.planNombre}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSlateLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Arancel & Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.textSlateMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Fecha: $fechaStr',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSlateMuted),
                          ),
                        ],
                      ),
                      Text(
                        'Bs. ${boleta.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: AppColors.borderSubtle, height: 20),

                  // Ver Boleta PDF Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        VisorPdfScreen.open(
                          context,
                          title: 'Comprobante ${boleta.numeroBoleta}',
                          documentBuilder: () => PdfBoletaPagoBuilder.buildPdf(boleta),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 15, color: AppColors.textSlateLight),
                      label: const Text('Descargar Comprobante PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSlateLight,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
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
