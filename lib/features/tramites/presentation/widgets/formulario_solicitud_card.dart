import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      statusColor = AppColors.successLight;
      statusBg = AppColors.successEmerald.withValues(alpha: 0.15);
      statusBorder = AppColors.successEmerald;
    } else if (isPendiente) {
      statusColor = AppColors.solarGold;
      statusBg = AppColors.solarAmber.withValues(alpha: 0.15);
      statusBorder = AppColors.solarGold;
    } else {
      statusColor = AppColors.accentVibrant;
      statusBg = AppColors.accentVibrant.withValues(alpha: 0.15);
      statusBorder = AppColors.accentVibrant;
    }

    final fechaStr = formulario.fechaRegistro != null
        ? '${formulario.fechaRegistro!.day.toString().padLeft(2, '0')}/${formulario.fechaRegistro!.month.toString().padLeft(2, '0')}/${formulario.fechaRegistro!.year}'
        : 'Reciente';

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
            Container(
              height: 3.0,
              color: isAprobado ? AppColors.successEmerald : AppColors.primaryCrimson,
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
                                size: 16, color: AppColors.solarGold),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                formulario.numeroFormulario,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.solarGold,
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
                          border: Border.all(color: statusBorder, width: 0.8),
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
                      color: AppColors.textWhite,
                    ),
                  ),

                  // Horario asignado
                  if (formulario.horarioTexto != null && formulario.horarioTexto!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.textSlateMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formulario.horarioTexto!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSlateLight,
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
                        const Icon(Icons.credit_card, size: 14, color: AppColors.successLight),
                        const SizedBox(width: 4),
                        Text(
                          formulario.planNombre!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successLight,
                          ),
                        ),
                        if (formulario.tarifaPrecio != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(Bs. ${formulario.tarifaPrecio!.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSlateMuted,
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
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textSlateMuted),
                        const SizedBox(width: 4),
                        Text(
                          formulario.usuarioNombre!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSlateLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  const SizedBox(height: 10),

                  // Acciones y Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: AppColors.textSlateMuted),
                          const SizedBox(width: 4),
                          Text(
                            fechaStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSlateMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (formulario.documentosCount > 0) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => DocumentosSolicitudModal.show(context, formulario),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.carbonSurfaceMuted,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.folder_shared_outlined,
                                        size: 12, color: AppColors.solarGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Docs (${formulario.documentosCount})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.solarGold,
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
                      OutlinedButton.icon(
                        onPressed: () {
                          VisorPdfScreen.open(
                            context,
                            title: 'Formulario ${formulario.numeroFormulario}',
                            documentBuilder: () =>
                                PdfFormularioDubssBuilder.buildPdf(formulario),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.solarGold,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
