import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../documentos/presentation/screens/documento_preview_screen.dart';
import '../../data/models/formulario_solicitud_model.dart';

class DocumentosSolicitudModal extends StatelessWidget {
  final FormularioSolicitudModel formulario;

  const DocumentosSolicitudModal({
    super.key,
    required this.formulario,
  });

  static Future<void> show(BuildContext context, FormularioSolicitudModel formulario) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DocumentosSolicitudModal(formulario: formulario),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = formulario.documentos;
    final maxH = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
                      color: AppColors.accentVibrant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Documentación Digital Anexada',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          'Solicitud: ${formulario.numeroFormulario}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSlateMuted,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // User Info Banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.carbonSurfaceMuted,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryCrimson.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppColors.accentVibrant),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formulario.usuarioNombre ?? 'Socio Universitario',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'C.I.: ${formulario.usuarioCi ?? 'S/N'} • R.U.: ${formulario.usuarioRegistro ?? 'S/N'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSlateMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '${docs.length} ${docs.length == 1 ? 'doc' : 'docs'}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.solarGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: docs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(
                                Icons.folder_open_rounded,
                                color: AppColors.accentVibrant,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sin Documentos Digitales',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'El postulante no ha cargado documentos digitales o presentó fotocopias físicas en ventanilla.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSlateMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: docs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final isPdf = doc.isPdf;

                        return Material(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              DocumentoPreviewScreen.open(context, doc);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(
                                      isPdf
                                          ? Icons.picture_as_pdf_rounded
                                          : Icons.image_rounded,
                                      color: isPdf
                                          ? AppColors.accentVibrant
                                          : AppColors.solarGold,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc.displayTitle,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textWhite,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text(
                                              doc.displayTipoNombre,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.accentVibrant,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text('•', style: TextStyle(color: AppColors.borderSubtle)),
                                            const SizedBox(width: 6),
                                            Text(
                                              doc.formattedDate,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSlateMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.carbonSurface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.borderSubtle),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSlateLight),
                                        SizedBox(width: 4),
                                        Text(
                                          'Ver',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSlateLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
