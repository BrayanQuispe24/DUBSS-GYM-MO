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
          backgroundColor: AppColors.accentVibrant,
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
          backgroundColor: AppColors.successEmerald,
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
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentVibrant, size: 22),
            SizedBox(width: 10),
            Text(
              'Garita & Control de Acceso',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSlateLight),
            tooltip: 'Actualizar marcaciones',
            onPressed: () =>
                ref.read(accesosNotifierProvider.notifier).cargarRegistros(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(accesosNotifierProvider.notifier).cargarRegistros(),
        color: AppColors.accentVibrant,
        backgroundColor: AppColors.carbonSurface,
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

              // KPI CARDS DE AFORO EN VIVO (Crimson Boxed-Sharpness)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryCrimson, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentVibrant, width: 1.0),
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
                                color: AppColors.solarGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Socios en el Gimnasio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.carbonSurface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.successEmerald, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.successEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$aforo Activos',
                                style: const TextStyle(
                                  color: AppColors.successEmerald,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.carbonSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.login_rounded,
                                    color: AppColors.successEmerald, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Entradas Hoy',
                                      style: TextStyle(
                                          color: AppColors.textSlateMuted,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '$totalEntradasHoy',
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
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
                              color: AppColors.carbonSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.logout_rounded,
                                    color: AppColors.accentVibrant, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Salidas Hoy',
                                      style: TextStyle(
                                          color: AppColors.textSlateMuted,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '$totalSalidasHoy',
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
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
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text(
                        'Escanear Pase QR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCrimson,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: const BorderSide(color: AppColors.accentVibrant),
                        ),
                        elevation: 0,
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
                            ? Icons.close
                            : Icons.how_to_reg_outlined,
                        size: 18,
                        color: AppColors.solarGold,
                      ),
                      label: Text(
                        _mostrarRegistroManual ? 'Cerrar' : 'Manual',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.solarGold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: AppColors.solarGold, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
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
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note,
                              color: AppColors.accentVibrant, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Marcación Directa por Recepción',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ciController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'C.I. o ID de Usuario *',
                          labelStyle: const TextStyle(
                              fontSize: 12, color: AppColors.textSlateMuted),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              size: 18, color: AppColors.textSlateMuted),
                          filled: true,
                          fillColor: AppColors.carbonSurfaceMuted,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.accentVibrant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nombreManualController,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Nombre del Atleta (opcional)',
                          labelStyle: const TextStyle(
                              fontSize: 12, color: AppColors.textSlateMuted),
                          prefixIcon: const Icon(Icons.person_outline,
                              size: 18, color: AppColors.textSlateMuted),
                          filled: true,
                          fillColor: AppColors.carbonSurfaceMuted,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: AppColors.accentVibrant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                                backgroundColor: AppColors.successEmerald,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
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
                                backgroundColor: AppColors.accentVibrant,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
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
                          color: AppColors.accentVibrant, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Marcaciones en Vivo (${state.filteredRegistros.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // BARRA DE BÚSQUEDA
              TextField(
                controller: _searchController,
                onChanged: (val) => ref
                    .read(accesosNotifierProvider.notifier)
                    .setSearchQuery(val),
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Filtrar por nombre, C.I. o código...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.textSlateMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(accesosNotifierProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.carbonSurface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.accentVibrant),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // LISTADO DE REGISTROS DE ACCESO
              if (state.isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.accentVibrant),
                  ),
                ),
              ] else if (state.filteredRegistros.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.person_search_outlined,
                          size: 40, color: AppColors.textSlateMuted),
                      SizedBox(height: 10),
                      Text(
                        'No hay marcaciones registradas para el filtro seleccionado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSlateLight,
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
                        ? AppColors.successEmerald.withValues(alpha: 0.15)
                        : AppColors.accentVibrant.withValues(alpha: 0.15);
                    final Color badgeText = isEntrada
                        ? AppColors.successEmerald
                        : AppColors.accentVibrant;

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
                        color: AppColors.carbonSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeText.withValues(alpha: 0.3)),
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
                                    color: AppColors.textWhite,
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
                                          color: AppColors.textSlateMuted,
                                        ),
                                      ),
                                      const Text(' • ',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.borderSubtle)),
                                    ],
                                    Text(
                                      horaFormato,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.solarGold,
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
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeText.withValues(alpha: 0.4)),
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
