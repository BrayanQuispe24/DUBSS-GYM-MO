import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/accesos_provider.dart';
import '../widgets/resultado_acceso_banner.dart';
import '../../../tramites/presentation/screens/escaner_qr_screen.dart';

class GaritaScreen extends ConsumerStatefulWidget {
  const GaritaScreen({super.key});

  @override
  ConsumerState<GaritaScreen> createState() => _GaritaScreenState();
}

class _GaritaScreenState extends ConsumerState<GaritaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _nombreManualController = TextEditingController();
  bool _mostrarRegistroManual = false;
  bool _isSavingManual = false;

  @override
  void dispose() {
    _searchController.dispose();
    _ciController.dispose();
    _nombreManualController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistroManual(String tipo) async {
    final ci = _ciController.text.trim();
    if (ci.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese el C.I. o ID del socio para registrar marcación.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final idUsuario = int.tryParse(ci) ?? 1;
    setState(() => _isSavingManual = true);

    final success = await ref
        .read(accesosNotifierProvider.notifier)
        .registrarMarcacionManual(
          idUsuario: idUsuario,
          tipo: tipo,
          nombreUsuario: _nombreManualController.text.trim().isNotEmpty
              ? _nombreManualController.text.trim()
              : 'Socio C.I. $ci',
        );

    setState(() => _isSavingManual = false);

    if (success && mounted) {
      _ciController.clear();
      _nombreManualController.clear();
      setState(() => _mostrarRegistroManual = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcación de $tipo registrada con éxito'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accesosNotifierProvider);
    final aforo = state.aforoActual;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final totalEntradasHoy = state.registros
        .where((r) => r.isEntrada && r.fechaHora.startsWith(todayStr))
        .length;
    final totalSalidasHoy = state.registros
        .where((r) => !r.isEntrada && r.fechaHora.startsWith(todayStr))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Garita & Control de Acceso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Actualizar marcaciones',
            onPressed: () =>
                ref.read(accesosNotifierProvider.notifier).cargarRegistros(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(accesosNotifierProvider.notifier).cargarRegistros(),
        color: AppColors.navyBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de resultado del último escaneo
              if (state.lastScanResult != null)
                ResultadoAccesoBanner(
                  result: state.lastScanResult!,
                  onDismiss: () =>
                      ref.read(accesosNotifierProvider.notifier).clearLastScan(),
                ),

              // KPI CARDS DE AFORO EN VIVO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003B70), Color(0xFF001C38)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003B70).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AFORO EN TIEMPO REAL',
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Socios en el Gimnasio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF22C55E)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$aforo Activos',
                                style: const TextStyle(
                                  color: Color(0xFFDCFCE7),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.login_rounded,
                                    color: Color(0xFF4ADE80), size: 22),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Entradas Hoy',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 10.5),
                                    ),
                                    Text(
                                      '$totalEntradasHoy',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.logout_rounded,
                                    color: Color(0xFFF87171), size: 22),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Salidas Hoy',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 10.5),
                                    ),
                                    Text(
                                      '$totalSalidasHoy',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // BOTONES DE ACCIÓN RÁPIDA: ESCÁNER Y MARCACIÓN MANUAL
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        EscanerQRScreen.open(context);
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text(
                        'Escanear Pase QR',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mostrarRegistroManual = !_mostrarRegistroManual;
                        });
                      },
                      icon: Icon(
                        _mostrarRegistroManual
                            ? Icons.close_rounded
                            : Icons.how_to_reg_rounded,
                        size: 18,
                        color: AppColors.navyBlue,
                      ),
                      label: Text(
                        _mostrarRegistroManual ? 'Cerrar' : 'Manual',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: AppColors.navyBlue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // FORMULARIO DESPLEGABLE DE REGISTRO MANUAL
              if (_mostrarRegistroManual) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note_rounded,
                              color: AppColors.navyBlue, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Marcación Directa por Recepción',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ciController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'C.I. o ID de Usuario *',
                          labelStyle: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              size: 18, color: AppColors.navyBlue),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nombreManualController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Atleta (opcional)',
                          labelStyle: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.person_outline,
                              size: 18, color: AppColors.navyBlue),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSavingManual
                                  ? null
                                  : () => _handleRegistroManual('entrada'),
                              icon: const Icon(Icons.login, size: 16),
                              label: const Text(
                                'Registrar Entrada',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSavingManual
                                  ? null
                                  : () => _handleRegistroManual('salida'),
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text(
                                'Registrar Salida',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // BUSCADOR Y ENCABEZADO DE HISTORIAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_toggle_off_rounded,
                          color: AppColors.navyBlue, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Marcaciones en Vivo (${state.filteredRegistros.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // BARRA DE BÚSQUEDA
              TextField(
                controller: _searchController,
                onChanged: (val) => ref
                    .read(accesosNotifierProvider.notifier)
                    .setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Filtrar por nombre, C.I. o código...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(accesosNotifierProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // LISTADO DE REGISTROS DE ACCESO
              if (state.isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.navyBlue),
                  ),
                ),
              ] else if (state.filteredRegistros.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'No hay marcaciones registradas para el filtro seleccionado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredRegistros.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final reg = state.filteredRegistros[index];
                    final isEntrada = reg.isEntrada;
                    final Color badgeBg = isEntrada
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2);
                    final Color badgeText = isEntrada
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C);

                    DateTime? parsedDate;
                    try {
                      parsedDate = DateTime.parse(reg.fechaHora);
                    } catch (_) {}

                    final horaFormato = parsedDate != null
                        ? '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}'
                        : reg.fechaHora;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEntrada
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: badgeText,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reg.nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (reg.usuarioCi != null &&
                                        reg.usuarioCi!.isNotEmpty) ...[
                                      Text(
                                        'CI: ${reg.usuarioCi}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const Text(' • ',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFFCBD5E1))),
                                    ],
                                    Text(
                                      horaFormato,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0077D4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reg.tipo.toUpperCase(),
                              style: TextStyle(
                                color: badgeText,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
