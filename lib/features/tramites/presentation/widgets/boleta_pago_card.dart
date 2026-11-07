import 'package:flutter/material.dart';
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
    final statusColor = isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusBg = isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);
    final statusBorder = isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A);

    final fechaStr = boleta.fechaPago != null
        ? '${boleta.fechaPago!.day.toString().padLeft(2, '0')}/${boleta.fechaPago!.month.toString().padLeft(2, '0')}/${boleta.fechaPago!.year}'
        : 'Sin fecha';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: const Color(0xFF0077D4)),
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
                          const Icon(Icons.receipt_outlined, size: 16, color: Color(0xFF0077D4)),
                          const SizedBox(width: 6),
                          Text(
                            boleta.numeroBoleta,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0077D4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBorder),
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
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  if (boleta.planNombre != null && boleta.planNombre!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Plan: ${boleta.planNombre}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Date, Method and Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: $fechaStr',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          Text(
                            boleta.metodoPago,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      Text(
                        'Bs. ${boleta.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0077D4),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Actions: Ver Boleta PDF
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
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('Ver Boleta PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0077D4),
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                        backgroundColor: const Color(0xFFF0F9FF),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
