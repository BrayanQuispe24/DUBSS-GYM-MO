import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/tramites_remote_datasource.dart';
import '../../data/models/boleta_inscripcion_model.dart';
import '../../data/models/qr_acceso_model.dart';

class QRPaseModal extends ConsumerStatefulWidget {
  final BoletaInscripcionModel boleta;

  const QRPaseModal({
    super.key,
    required this.boleta,
  });

  static Future<void> show(BuildContext context, BoletaInscripcionModel boleta) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QRPaseModal(boleta: boleta),
    );
  }

  @override
  ConsumerState<QRPaseModal> createState() => _QRPaseModalState();
}

class _QRPaseModalState extends ConsumerState<QRPaseModal> {
  QRAccesoModel? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQrPass();
  }

  Future<void> _loadQrPass() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ds = ref.read(tramitesRemoteDataSourceProvider);
      final qr = await ds.getBoletaInscripcionQR(widget.boleta.id);
      if (mounted) {
        setState(() {
          _qrData = qr;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback construyendo payload local para que el alumno no se quede sin acceso
        final fallbackPayload =
            'UAGRM-ACCESO:${widget.boleta.id}:${widget.boleta.numeroBoleta}:${widget.boleta.idUsuario}';
        setState(() {
          _qrData = QRAccesoModel(
            boletaId: widget.boleta.id,
            numeroBoleta: widget.boleta.numeroBoleta,
            usuarioNombre: widget.boleta.usuarioNombre ?? 'Socio Universitario',
            usuarioRu: widget.boleta.usuarioRu,
            usuarioCi: widget.boleta.usuarioCi,
            disciplina: widget.boleta.disciplina,
            horarioTexto: widget.boleta.horarioFormateado,
            fechaInicio: widget.boleta.fechaInicio?.toIso8601String() ?? '',
            fechaFin: widget.boleta.fechaFin?.toIso8601String() ?? '',
            estado: widget.boleta.estado,
            monto: widget.boleta.monto,
            qrPayload: fallbackPayload,
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: AppColors.accentVibrant,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pase Digital de Acceso',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Text(
                            'Torniquete & Gimnasio DUBSS',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSlateMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textSlateMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),

              Padding(
                padding: const EdgeInsets.all(24),
                child: _isLoading
                    ? const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryCrimson),
                        ),
                      )
                    : Column(
                        children: [
                          // Badge Habilitado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.boleta.isActiva
                                  ? AppColors.successEmerald.withValues(alpha: 0.15)
                                  : AppColors.primaryCrimson.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: widget.boleta.isActiva
                                    ? AppColors.successEmerald.withValues(alpha: 0.35)
                                    : AppColors.primaryCrimson.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.boleta.isActiva ? Icons.verified : Icons.warning_amber,
                                  size: 14,
                                  color: widget.boleta.isActiva
                                      ? AppColors.successLight
                                      : AppColors.accentVibrant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.boleta.isActiva
                                      ? 'MEMBRESÍA ACTIVA - INGRESO AUTORIZADO'
                                      : 'MEMBRESÍA EXPIRADA',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: widget.boleta.isActiva
                                        ? AppColors.successLight
                                        : AppColors.accentVibrant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta Contenedora del Código QR (blanco para alta legibilidad en lectores ópticos)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                            ),
                            child: QrImageView(
                              data: _qrData?.qrPayload ?? widget.boleta.numeroBoleta,
                              version: QrVersions.auto,
                              size: 210.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF0B0B0D),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF0B0B0D),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Datos del Alumno y Disciplina
                          Text(
                            _qrData?.usuarioNombre ?? widget.boleta.usuarioNombre ?? 'Socio Universitario',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.boleta.disciplina} • ${widget.boleta.numeroBoleta}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.solarGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.schedule, size: 14, color: AppColors.textSlateMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Horario: ${widget.boleta.horarioFormateado}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSlateLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nota de Uso
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.carbonSurfaceMuted,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.accentVibrant),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Acerque la pantalla del teléfono al lector óptico del torniquete para registrar automáticamente su ingreso o salida.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSlateLight,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
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
  }
}
