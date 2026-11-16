import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../documentos/data/models/documento_model.dart';
import '../../../documentos/presentation/screens/documento_preview_screen.dart';
import '../../data/datasources/tramites_remote_datasource.dart';
import '../providers/tramites_provider.dart';

class FormularioDubssCreateModal extends ConsumerStatefulWidget {
  const FormularioDubssCreateModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FormularioDubssCreateModal(),
    );
  }

  @override
  ConsumerState<FormularioDubssCreateModal> createState() =>
      _FormularioDubssCreateModalState();
}

class _FormularioDubssCreateModalState
    extends ConsumerState<FormularioDubssCreateModal> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late final String _numeroFormulario;
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _disciplinas = [];
  List<Map<String, dynamic>> _horariosPivot = [];
  List<Map<String, dynamic>> _planes = [];
  List<Map<String, dynamic>> _userDocumentos = [];

  int? _selectedDisciplinaId;
  int? _selectedDisciplinaHorarioId;
  int? _selectedPlanId;
  String? _selectedHorarioTexto;

  // Datos personales y académicos
  final _celularController = TextEditingController();
  final _domicilioController = TextEditingController();
  final _facultadController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  DateTime? _fechaNacimiento;
  String _sexo = 'Masculino';
  String _grupoSanguineo = 'O+';

  // Cuestionario Médico: 1. Cardiovasculares
  bool _tieneCardio = false;
  final _detCardioController = TextEditingController();
  bool _tieneProcCardio = false;
  final _detProcCardioController = TextEditingController();

  // 2. Condiciones Médicas
  bool _tieneHipertension = false;
  bool _tienePulmonar = false;
  bool _tieneDiabetes = false;
  bool _tieneOsteoarticular = false;
  bool _tieneNeurologica = false;
  bool _tieneConvulsiones = false;
  bool _tieneLesiones = false;
  bool _tieneAlergias = false;
  final _detCondicionesController = TextEditingController();

  // 3. Intervenciones y antecedentes deportivos
  bool _tieneCirugia = false;
  final _detCirugiaController = TextEditingController();
  bool _tieneFracturas = false;
  final _detFracturasController = TextEditingController();
  bool _tieneSintomas = false;
  final _detSintomasController = TextEditingController();

  // 4. Declaración Jurada
  bool _aceptaDeclaracion = false;

  @override
  void initState() {
    super.initState();
    final randomNum = 1000 + Random().nextInt(9000);
    _numeroFormulario = 'DUBSS-FR-03-${DateTime.now().year}-$randomNum';
    _loadInitialData();
  }

  @override
  void dispose() {
    _celularController.dispose();
    _domicilioController.dispose();
    _facultadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _detCardioController.dispose();
    _detProcCardioController.dispose();
    _detCondicionesController.dispose();
    _detCirugiaController.dispose();
    _detFracturasController.dispose();
    _detSintomasController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final ds = ref.read(tramitesRemoteDataSourceProvider);
    final user = ref.read(authNotifierProvider).user;

    if (user != null) {
      if (user.telefono != null && user.telefono!.isNotEmpty) {
        _celularController.text = user.telefono!;
      }
    }

    try {
      final discs = await ds.getDisciplinas();
      final hors = await ds.getDisciplinaHorarios();
      final pls = await ds.getPlanes();

      // Cargar documentos del usuario si existen
      List<Map<String, dynamic>> userDocs = [];
      try {
        final rawDocs = await ds.getDocumentosUsuario();
        userDocs = rawDocs;
      } catch (_) {
        userDocs = [];
      }

      if (mounted) {
        setState(() {
          _disciplinas = discs;
          _horariosPivot = hors;
          _planes = pls;
          _userDocumentos = userDocs;
          _isLoadingData = false;

          if (_disciplinas.isNotEmpty) {
            _selectedDisciplinaId = _disciplinas.first['id'] as int?;
          }
          if (_planes.isNotEmpty) {
            _selectedPlanId = _planes.first['id'] as int?;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  List<Map<String, dynamic>> get _availableHorarios {
    if (_selectedDisciplinaId == null) return [];
    return _horariosPivot
        .where((dh) => dh['id_disciplina'] == _selectedDisciplinaId)
        .toList();
  }

  String get _imcCalculado {
    final p = double.tryParse(_pesoController.text);
    final a = double.tryParse(_alturaController.text);
    if (p == null || a == null || a <= 0) return '-';
    final aMetros = a / 100;
    final imc = p / (aMetros * aMetros);
    return imc.toStringAsFixed(2);
  }

  Future<void> _selectFechaNacimiento() async {
    try {
      final now = DateTime.now();
      final initial = _fechaNacimiento ?? DateTime(2000, 1, 1);
      final safeInitial = initial.isAfter(now) ? now : (initial.isBefore(DateTime(1940)) ? DateTime(1940) : initial);

      final picked = await showDatePicker(
        context: context,
        initialDate: safeInitial,
        firstDate: DateTime(1940),
        lastDate: now,
        helpText: 'Seleccione su Fecha de Nacimiento',
        cancelText: 'Cancelar',
        confirmText: 'Aceptar',
      );
      if (picked != null && mounted) {
        setState(() => _fechaNacimiento = picked);
      }
    } catch (e) {
      debugPrint('Error al seleccionar fecha de nacimiento: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitFormulario() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Por favor complete todos los campos obligatorios del formulario.';
      });
      _scrollToBottom();
      return;
    }

    if (_selectedDisciplinaId == null) {
      setState(() {
        _errorMessage = 'Por favor seleccione una disciplina deportiva.';
      });
      _scrollToBottom();
      return;
    }

    if (!_aceptaDeclaracion) {
      setState(() {
        _errorMessage = 'Debe aceptar el Reglamento Interno y la Declaración Jurada para enviar la solicitud.';
      });
      _scrollToBottom();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authNotifierProvider).user;
      final userId = user?.id ?? 0;

      final payload = {
        'numero_formulario': _numeroFormulario,
        'id_disciplina': _selectedDisciplinaId,
        'id_disciplina_horario': _selectedDisciplinaHorarioId,
        'id_plan': _selectedPlanId,
        'id_usuario': userId,
        'horario': _selectedHorarioTexto,
        'estado': 'pendiente',
        'fecha_registro': DateTime.now().toIso8601String().split('T')[0],
        'facultad_carrera': _facultadController.text.trim(),
        'domicilio': _domicilioController.text.trim(),
        'celular': _celularController.text.trim(),
        'sexo': _sexo,
        'grupo_sanguineo': _grupoSanguineo,
        'fecha_nacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
        'peso': double.tryParse(_pesoController.text),
        'altura': double.tryParse(_alturaController.text),
        'antecedentes': {
          'tiene_enfermedades_cardiovasculares': _tieneCardio,
          'detalle_enfermedades_cardiovasculares': _tieneCardio ? _detCardioController.text.trim() : null,
          'se_realizo_intervencion_cardiovascular': _tieneProcCardio,
          'detalle_intervencion_cardiovascular': _tieneProcCardio ? _detProcCardioController.text.trim() : null,
          'tiene_hipertension_arterial': _tieneHipertension,
          'tiene_enfermedades_pulmonares': _tienePulmonar,
          'tiene_diabetes': _tieneDiabetes,
          'tiene_enfermedades_osteoarticulares': _tieneOsteoarticular,
          'tiene_enfermedades_neurologicas': _tieneNeurologica,
          'tiene_convulsiones': _tieneConvulsiones,
          'tiene_lesiones_recientes': _tieneLesiones,
          'tiene_alergias_conocidas': _tieneAlergias,
          'detalle_condiciones': _detCondicionesController.text.trim().isNotEmpty
              ? _detCondicionesController.text.trim()
              : null,
          'tiene_intervencion_quirurgica': _tieneCirugia,
          'detalle_intervencion_quirurgica': _tieneCirugia ? _detCirugiaController.text.trim() : null,
          'sufrio_fracturas_oseas': _tieneFracturas,
          'detalle_fracturas_oseas': _tieneFracturas ? _detFracturasController.text.trim() : null,
          'sufrio_algun_sintoma_durante_deporte': _tieneSintomas,
          'detalle_sintomas_durante_deporte': _tieneSintomas ? _detSintomasController.text.trim() : null,
        },
      };

      final ds = ref.read(tramitesRemoteDataSourceProvider);
      await ds.createFormularioSolicitud(payload);

      // Refrescar listado
      ref.invalidate(formulariosSolicitudProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('¡Solicitud DUBSS-FR-03 registrada exitosamente!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceAll('Exception: ', '').replaceAll('AppException: ', '');
        setState(() {
          _isSubmitting = false;
          _errorMessage = cleanMsg;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = ref.watch(authNotifierProvider).user;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
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
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
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
                      Icons.description_outlined,
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
                          'Formulario DUBSS-FR-03',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          'Código generado: $_numeroFormulario',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSlateMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

            // Banner fijo superior de error (garantiza visibilidad inmediata ante cualquier fallo)
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryCrimson,
                  border: Border(
                    bottom: BorderSide(color: AppColors.accentVibrant, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

            // Form Body
            Expanded(
              child: _isLoadingData
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryCrimson),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(18),
                        children: [
                          // ──────────────────────────────────────────
                          // SECCIÓN 1: DATOS DE LA SOLICITUD
                          // ──────────────────────────────────────────
                          _buildSectionCard(
                            title: '1. Datos de Solicitud y Membresía',
                            icon: Icons.assignment_turned_in_outlined,
                            iconColor: AppColors.accentVibrant,
                            children: [
                              // Socio
                              TextFormField(
                                initialValue: user?.name ?? '${user?.nombre ?? ''} ${user?.apellido ?? ''}'.trim(),
                                readOnly: true,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Socio / Universitario', Icons.person_outline),
                              ),
                              const SizedBox(height: 12),

                              // Selector Disciplina
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: _selectedDisciplinaId,
                                dropdownColor: AppColors.carbonSurfaceMuted,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Disciplina Deportiva', Icons.fitness_center),
                                items: _disciplinas.map((d) {
                                  return DropdownMenuItem<int>(
                                    value: d['id'] as int,
                                    child: Text(
                                      d['nombre']?.toString() ?? 'Sin nombre',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedDisciplinaId = val;
                                    _selectedDisciplinaHorarioId = null;
                                    _selectedHorarioTexto = null;
                                  });
                                },
                                validator: (val) => val == null ? 'Seleccione una disciplina' : null,
                              ),
                              const SizedBox(height: 12),

                              // Selector Plan
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: _selectedPlanId,
                                dropdownColor: AppColors.carbonSurfaceMuted,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Plan de Membresía / Tarifa', Icons.card_membership),
                                items: _planes.map((p) {
                                  final tarifa = p['tarifa'];
                                  final precio = tarifa is Map ? ' (Bs. ${tarifa['precio']})' : '';
                                  return DropdownMenuItem<int>(
                                    value: p['id'] as int,
                                    child: Text(
                                      '${p['nombre'] ?? 'Plan'}$precio',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedPlanId = val),
                              ),
                              const SizedBox(height: 12),

                              // Selector Horario
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: _selectedDisciplinaHorarioId,
                                dropdownColor: AppColors.carbonSurfaceMuted,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5),
                                decoration: _inputDecoration('Horario y Turno de Asistencia', Icons.schedule),
                                hint: Text(
                                  _availableHorarios.isEmpty
                                      ? 'Horario estándar / Por confirmar'
                                      : 'Seleccione turno con cupo',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                                ),
                                items: _availableHorarios.map((dh) {
                                  final hor = dh['horario'] ?? {};
                                  final dia = hor['dia_semana'] ?? hor['dias'] ?? '';
                                  final ini = hor['hora_inicio'] ?? '';
                                  final fin = hor['hora_fin'] ?? '';
                                  final label = '$dia ($ini - $fin)'.trim();
                                  final cuposDisp = dh['cupos_disponibles'] ?? dh['cupo_maximo'] ?? 0;
                                  final cupoMax = dh['cupo_maximo'] ?? 0;
                                  return DropdownMenuItem<int>(
                                    value: dh['id'] as int,
                                    child: Text(
                                      '$label • Cupos: $cuposDisp/$cupoMax',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedDisciplinaHorarioId = val;
                                    final found = _availableHorarios.firstWhere(
                                      (dh) => dh['id'] == val,
                                      orElse: () => {},
                                    );
                                    final hor = found['horario'] ?? {};
                                    _selectedHorarioTexto =
                                        '${hor['dia_semana'] ?? ''}: ${hor['hora_inicio'] ?? ''} - ${hor['hora_fin'] ?? ''}';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ──────────────────────────────────────────
                          // SECCIÓN 2: DATOS PERSONALES DEL SOCIO
                          // ──────────────────────────────────────────
                          _buildSectionCard(
                            title: '2. Datos Personales & Físicos',
                            icon: Icons.person_pin_outlined,
                            iconColor: AppColors.solarAmber,
                            children: [
                              TextFormField(
                                controller: _facultadController,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Facultad / Carrera / Unidad', Icons.school_outlined),
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _domicilioController,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Domicilio Actual', Icons.home_outlined),
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _celularController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDecoration('Celular / Teléfono', Icons.phone_android),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un celular' : null,
                              ),
                              const SizedBox(height: 12),

                              // Fecha de Nacimiento
                              InkWell(
                                onTap: _selectFechaNacimiento,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: AppColors.carbonSurfaceMuted,
                                    border: Border.all(color: AppColors.borderSubtle),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cake_outlined, color: AppColors.accentVibrant, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _fechaNacimiento != null
                                              ? 'Fecha Nac.: ${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}'
                                              : 'Seleccionar Fecha de Nacimiento',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: _fechaNacimiento != null ? AppColors.textWhite : AppColors.textSlateMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Sexo y Grupo Sanguíneo
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _sexo,
                                      dropdownColor: AppColors.carbonSurfaceMuted,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5),
                                      decoration: _inputDecoration('Sexo', Icons.transgender),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Masculino',
                                          child: Text(
                                            'Masculino (M)',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12.5, color: AppColors.textWhite),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Femenino',
                                          child: Text(
                                            'Femenino (F)',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12.5, color: AppColors.textWhite),
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) => setState(() => _sexo = val ?? 'Masculino'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _grupoSanguineo,
                                      dropdownColor: AppColors.carbonSurfaceMuted,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5),
                                      decoration: _inputDecoration('G. Sang.', Icons.bloodtype_outlined),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'O+',
                                          child: Text('O+', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'O-',
                                          child: Text('O-', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'A+',
                                          child: Text('A+', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'A-',
                                          child: Text('A-', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B+',
                                          child: Text('B+', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B-',
                                          child: Text('B-', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB+',
                                          child: Text('AB+', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB-',
                                          child: Text('AB-', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                                        ),
                                      ],
                                      onChanged: (val) => setState(() => _grupoSanguineo = val ?? 'O+'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Peso, Altura e IMC
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _pesoController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _inputDecoration('Peso (kg)', Icons.monitor_weight_outlined),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _alturaController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _inputDecoration('Altura (cm)', Icons.height),
                                    ),
                                  ),
                                ],
                              ),
                              if (_imcCalculado != '-') ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.carbonSurface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.analytics_outlined, color: AppColors.solarGold, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Índice de Masa Corporal (IMC): $_imcCalculado kg/m²',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.solarGold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ──────────────────────────────────────────
                          // SECCIÓN 3: CUESTIONARIO MÉDICO COMPLETO
                          // ──────────────────────────────────────────
                          _buildSectionCard(
                            title: '3. Cuestionario Médico Oficial',
                            icon: Icons.health_and_safety_outlined,
                            iconColor: AppColors.primaryCrimson,
                            children: [
                              const Text(
                                'Por favor responda con sinceridad las siguientes preguntas sobre su salud:',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSlateMuted),
                              ),
                              const SizedBox(height: 10),

                              // 1. Antecedentes Cardiovasculares
                              _buildQuestionHeader('1. Antecedentes Médicos Generales'),
                              _buildCheckboxQuestion(
                                label: '¿Tiene antecedentes de enfermedades cardiovasculares?',
                                value: _tieneCardio,
                                onChanged: (val) => setState(() => _tieneCardio = val),
                                detailController: _detCardioController,
                                detailHint: 'Especifique antecedentes cardiovasculares...',
                              ),
                              _buildCheckboxQuestion(
                                label: '¿Se le ha realizado algún procedimiento cardiovascular (bypass, marcapasos, angioplastia)?',
                                value: _tieneProcCardio,
                                onChanged: (val) => setState(() => _tieneProcCardio = val),
                                detailController: _detProcCardioController,
                                detailHint: 'Especifique procedimiento realizado...',
                              ),
                              const SizedBox(height: 10),

                              // 2. Condiciones Médicas (Checkboxes)
                              _buildQuestionHeader('2. ¿Padece alguna de las siguientes condiciones?'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildConditionChip('Hipertensión', _tieneHipertension, (v) => setState(() => _tieneHipertension = v)),
                                  _buildConditionChip('Enf. Pulmonares', _tienePulmonar, (v) => setState(() => _tienePulmonar = v)),
                                  _buildConditionChip('Diabetes', _tieneDiabetes, (v) => setState(() => _tieneDiabetes = v)),
                                  _buildConditionChip('Osteoarticulares', _tieneOsteoarticular, (v) => setState(() => _tieneOsteoarticular = v)),
                                  _buildConditionChip('Neurológicas', _tieneNeurologica, (v) => setState(() => _tieneNeurologica = v)),
                                  _buildConditionChip('Convulsiones', _tieneConvulsiones, (v) => setState(() => _tieneConvulsiones = v)),
                                  _buildConditionChip('Lesiones músculo-articulares', _tieneLesiones, (v) => setState(() => _tieneLesiones = v)),
                                  _buildConditionChip('Alergias conocidas', _tieneAlergias, (v) => setState(() => _tieneAlergias = v)),
                                ],
                              ),
                              if (_tieneHipertension || _tienePulmonar || _tieneDiabetes || _tieneOsteoarticular || _tieneNeurologica || _tieneConvulsiones || _tieneLesiones || _tieneAlergias) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _detCondicionesController,
                                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                  decoration: _inputDecoration('Detalle de condición médica marcada', Icons.notes),
                                ),
                              ],
                              const SizedBox(height: 10),

                              // 3. Intervenciones y deportes
                              _buildQuestionHeader('3. Intervenciones y Antecedentes Deportivos'),
                              _buildCheckboxQuestion(
                                label: '¿Le realizaron alguna intervención quirúrgica?',
                                value: _tieneCirugia,
                                onChanged: (val) => setState(() => _tieneCirugia = val),
                                detailController: _detCirugiaController,
                                detailHint: 'Especifique intervención quirúrgica...',
                              ),
                              _buildCheckboxQuestion(
                                label: '¿Ha sufrido fracturas óseas?',
                                value: _tieneFracturas,
                                onChanged: (val) => setState(() => _tieneFracturas = val),
                                detailController: _detFracturasController,
                                detailHint: 'Especifique fracturas óseas...',
                              ),
                              _buildCheckboxQuestion(
                                label: '¿Ha sufrido mareos, deshidratación o pérdida de conocimiento durante el deporte?',
                                value: _tieneSintomas,
                                onChanged: (val) => setState(() => _tieneSintomas = val),
                                detailController: _detSintomasController,
                                detailHint: 'Detalle el episodio ocurrido...',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ──────────────────────────────────────────
                          // SECCIÓN 3.5: DOCUMENTACIÓN ADJUNTA REGISTRADA
                          // ──────────────────────────────────────────
                          _buildSectionCard(
                            title: '3.5. Documentación Digital Adjunta',
                            icon: Icons.folder_shared_outlined,
                            iconColor: AppColors.solarGold,
                            children: [
                              if (_userDocumentos.isNotEmpty)
                                Column(
                                  children: _userDocumentos.map((doc) {
                                    final tipo = doc['tipo_documento']?['nombre'] ?? doc['titulo'] ?? 'Documento';
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(4),
                                        onTap: () {
                                          try {
                                            final docModel = DocumentoModel.fromJson(doc);
                                            DocumentoPreviewScreen.open(context, docModel);
                                          } catch (e) {
                                            debugPrint('Error al previsualizar documento: $e');
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.carbonSurface,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.borderSubtle),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.picture_as_pdf_outlined, color: AppColors.accentVibrant, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(tipo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                                              ),
                                              const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textSlateLight),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.check_circle_rounded, color: AppColors.successEmerald, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCrimson.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline, color: AppColors.solarGold, size: 18),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No tienes documentos digitales cargados aún. Podrás adjuntarlos en la sección "Documentación Digital" o presentar fotocopias físicas.',
                                          style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ──────────────────────────────────────────
                          // SECCIÓN 4: REGLAMENTO Y DECLARACIÓN JURADA
                          // ──────────────────────────────────────────
                          _buildSectionCard(
                            title: '4. Reglamento Interno & Declaración Jurada',
                            icon: Icons.gavel_outlined,
                            iconColor: AppColors.accentVibrant,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.carbonSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reglas Principales del Gimnasio Universitario:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                                    ),
                                    SizedBox(height: 4),
                                    Text('• Reserva personal: Asistir en el horario registrado.', style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight)),
                                    Text('• Certificado médico: Plazo de 15 días si declaró condiciones.', style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight)),
                                    Text('• Indumentaria obligatoria: Ropa deportiva, zapatillas limpias y toallita.', style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight)),
                                    Text('• Deslinde legal por omisión o negligencia en el uso de máquinas.', style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCrimson.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.35)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DECLARACIÓN JURADA DUBSS-FR-03',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.solarGold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Declaro bajo juramento que los datos contenidos en esta ficha son exactos y verdaderos. Deslindo de responsabilidad al Gimnasio Universitario UAGRM por causas de salud preexistentes y me comprometo a cumplir el reglamento disciplinar.',
                                      style: TextStyle(fontSize: 11.5, color: AppColors.textSlateLight, height: 1.3),
                                    ),
                                    const SizedBox(height: 8),
                                    CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: const Text(
                                        'He leído, acepto el Reglamento Interno y firmo digitalmente la Declaración Jurada (DUBSS-FR-03)',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                                      ),
                                      value: _aceptaDeclaracion,
                                      activeColor: AppColors.primaryCrimson,
                                      checkColor: AppColors.textWhite,
                                      onChanged: (val) => setState(() => _aceptaDeclaracion = val ?? false),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Banner de error junto a los botones de acción
                          if (_errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.accentVibrant, width: 1.2),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.accentVibrant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => setState(() => _errorMessage = null),
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.textSlateMuted,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // BOTONES DE ACCIÓN
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: AppColors.borderSubtle),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: CrimsonButton(
                                  label: 'Enviar Solicitud DUBSS-FR-03',
                                  icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                                  isLoading: _isSubmitting,
                                  style: CrimsonButtonStyle.gradient,
                                  height: 48,
                                  onPressed: _isSubmitting ? null : _submitFormulario,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // WIDGETS AUXILIARES
  // ──────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurfaceMuted,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textWhite),
              ),
            ],
          ),
          const Divider(height: 18, color: AppColors.borderSubtle),
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textWhite),
      ),
    );
  }

  Widget _buildCheckboxQuestion({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController detailController,
    required String detailHint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                activeColor: AppColors.primaryCrimson,
                checkColor: AppColors.textWhite,
                onChanged: (v) => onChanged(v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSlateLight),
                  ),
                ),
              ),
            ],
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
              child: TextFormField(
                controller: detailController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: detailHint,
                  hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textSlateMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  filled: true,
                  fillColor: AppColors.carbonSurfaceMuted,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String label, bool isChecked, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500, color: isChecked ? AppColors.textWhite : AppColors.textSlateLight)),
      selected: isChecked,
      onSelected: onChanged,
      selectedColor: AppColors.primaryCrimson.withValues(alpha: 0.25),
      checkmarkColor: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: isChecked ? AppColors.accentVibrant : AppColors.borderSubtle),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
      prefixIcon: Icon(icon, color: AppColors.accentVibrant, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: AppColors.carbonSurface,
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
        borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.5),
      ),
    );
  }
}
