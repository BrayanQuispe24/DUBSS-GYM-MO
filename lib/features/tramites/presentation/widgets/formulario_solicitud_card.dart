import 'package:flutter/material.dart';
import '../../data/models/formulario_solicitud_model.dart';
import '../screens/visor_pdf_screen.dart';
import 'documentos_solicitud_modal.dart';
import 'pdf_formulario_dubss_builder.dart';

class FormularioSolicitudCard extends StatelessWidget {
  final FormularioSolicitudModel formulario;

  const FormularioSolicitudCard({
    super.key,
    required this.formulario,
  });

  @override
  Widget build(BuildContext context) {
    final isAprobado = formulario.isAprobado;
    final isPendiente = formulario.isPendiente;

    final Color statusColor;
    final Color statusBg;
    final Color statusBorder;

    if (isAprobado) {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
    } else if (isPendiente) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
    } else {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
    }

    final fechaStr = formulario.fechaRegistro != null
        ? '${formulario.fechaRegistro!.day.toString().padLeft(2, '0')}/${formulario.fechaRegistro!.month.toString().padLeft(2, '0')}/${formulario.fechaRegistro!.year}'
        : 'Reciente';

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
            Container(
              height: 3,
              color: isAprobado ? const Color(0xFF10B981) : const Color(0xFF0077D4),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nº Formulario y Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_outlined,
                                size: 16, color: Color(0xFF0077D4)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                formulario.numeroFormulario,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0077D4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBorder),
                        ),
                        child: Text(
                          formulario.estadoLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Disciplina
                  Text(
                    formulario.disciplinaNombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  // Horario asignado
                  if (formulario.horarioTexto != null && formulario.horarioTexto!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formulario.horarioTexto!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Plan y Tarifa
                  if (formulario.planNombre != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          formulario.planNombre!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                        if (formulario.tarifaPrecio != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(Bs. ${formulario.tarifaPrecio!.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Usuario / Socio Info
                  if (formulario.usuarioNombre != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          formulario.usuarioNombre!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),

                  // Acciones y Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            fechaStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (formulario.documentosCount > 0) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => DocumentosSolicitudModal.show(context, formulario),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFBAE6FD)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.folder_shared_outlined,
                                        size: 12, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Docs (${formulario.documentosCount})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Botón Ver PDF DUBSS-FR-03
                      FilledButton.icon(
                        onPressed: () {
                          VisorPdfScreen.open(
                            context,
                            title: 'Formulario ${formulario.numeroFormulario}',
                            documentBuilder: () =>
                                PdfFormularioDubssBuilder.buildPdf(formulario),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF3C7),
                          foregroundColor: const Color(0xFFD97706),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: Color(0xFFFCD34D)),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                        label: const Text(
                          'Ver PDF',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
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
