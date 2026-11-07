import 'package:flutter/material.dart';
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
    final statusColor = isActiva ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final statusBg = isActiva ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final statusBorder = isActiva ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);

    final fInicioStr = boleta.fechaInicio != null
        ? '${boleta.fechaInicio!.day.toString().padLeft(2, '0')}/${boleta.fechaInicio!.month.toString().padLeft(2, '0')}/${boleta.fechaInicio!.year}'
        : '-';

    final fFinStr = boleta.fechaFin != null
        ? '${boleta.fechaFin!.day.toString().padLeft(2, '0')}/${boleta.fechaFin!.month.toString().padLeft(2, '0')}/${boleta.fechaFin!.year}'
        : '-';

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
            Container(height: 3, color: statusColor),
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
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBorder),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0077D4),
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
                              const Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                'Vigencia: $fInicioStr al $fFinStr',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                'Turno: ${boleta.horarioFormateado}',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isActiva)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${boleta.diasRestantes} días rest.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0077D4),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Divider(height: 20),

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
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 15),
                        label: const Text('Boleta PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Generar / Mostrar Pase QR
                      FilledButton.icon(
                        onPressed: () {
                          QRPaseModal.show(context, boleta);
                        },
                        icon: const Icon(Icons.qr_code, size: 16),
                        label: const Text('Pase QR'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0077D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
