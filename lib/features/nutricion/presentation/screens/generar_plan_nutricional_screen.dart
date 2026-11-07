import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/recomendacion_nutricional_ia_model.dart';
import '../providers/generar_plan_ia_provider.dart';
import '../widgets/comida_detail_card.dart';
import '../widgets/macros_summary_widget.dart';

class GenerarPlanNutricionalScreen extends ConsumerStatefulWidget {
  const GenerarPlanNutricionalScreen({super.key});

  @override
  ConsumerState<GenerarPlanNutricionalScreen> createState() =>
      _GenerarPlanNutricionalScreenState();
}

class _GenerarPlanNutricionalScreenState
    extends ConsumerState<GenerarPlanNutricionalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Biometría
  int _edad = 23;
  String _sexo = 'masculino';
  double _pesoKg = 72.0;
  double _alturaCm = 174.0;

  // Actividad y Objetivo
  String _nivelActividad = 'moderado';
  String _objetivo = 'aumento_masa_muscular';
  int _comidasAlDia = 4;
  String _presupuesto = 'economico';

  // Preferencias
  final TextEditingController _restriccionesController = TextEditingController();
  final TextEditingController _alimentosEvitarController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void dispose() {
    _restriccionesController.dispose();
    _alimentosEvitarController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _ejecutarGeneracion() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final restricciones = _restriccionesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final alimentosNoDeseados = _alimentosEvitarController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final perfil = PerfilNutricionalInput(
      edad: _edad,
      sexo: _sexo,
      pesoKg: _pesoKg,
      alturaCm: _alturaCm,
      nivelActividad: _nivelActividad,
      objetivo: _objetivo,
      comidasAlDia: _comidasAlDia,
      restricciones: restricciones,
      alimentosNoDeseados: alimentosNoDeseados,
      presupuesto: _presupuesto,
      observacionesAdicionales: _observacionesController.text.trim().isNotEmpty
          ? _observacionesController.text.trim()
          : null,
    );

    final success = await ref
        .read(generarPlanIaProvider.notifier)
        .generarRecomendacion(perfil);

    if (!success && mounted) {
      final err = ref.read(generarPlanIaProvider).generationError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Error al contactar al servicio de IA.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _guardarPlanOficial() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar el plan oficial.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final success = await ref
        .read(generarPlanIaProvider.notifier)
        .guardarComoPlanOficial(
          idUsuario: user.id,
          nombreAtleta: user.nombreCompleto,
          objetivoCustom: _getObjetivoLabel(_objetivo),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('¡Plan oficial guardado exitosamente en tu cuenta!'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      context.pop();
    } else if (mounted) {
      final err = ref.read(generarPlanIaProvider).saveError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Error al guardar el plan oficial.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getObjetivoLabel(String key) {
    switch (key) {
      case 'perdida_grasa':
        return 'Pérdida de Grasa & Definición';
      case 'aumento_masa_muscular':
        return 'Aumento de Masa Muscular (Hipertrofia)';
      case 'definicion':
        return 'Definición Muscular Extrema';
      case 'rendimiento':
        return 'Rendimiento Atlético';
      case 'mantenimiento':
      default:
        return 'Mantenimiento & Salud';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generarPlanIaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF0077D4), size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Generador Nutricional IA',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
      body: state.isGenerating
          ? _buildLoadingAiView()
          : (state.recomendacion != null
              ? _buildResultadoView(state.recomendacion!, state.isSaving)
              : _buildFormularioView()),
    );
  }

  Widget _buildLoadingAiView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0077D4), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0077D4).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Generando tu Plan Nutricional',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Google Gemini 2.5 Flash está calculando tu TMB, requerimientos energéticos y estructurando recetas con ingredientes locales accesibles...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                color: Color(0xFF0077D4),
                backgroundColor: Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioView() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Banner introductorio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077D4), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077D4).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescripción Inteligente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Completa tus datos y la IA diseñará un plan estructurado con recetas, porciones y sustitutos económicos.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 1: DATOS BIOLÓGICOS
          _buildSectionTitle('1. DATOS BIOMÉTRICOS'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Sexo
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Sexo Biológico',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Masculino'),
                      selected: _sexo == 'masculino',
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onSelected: (val) {
                        if (val) setState(() => _sexo = 'masculino');
                      },
                      selectedColor: const Color(0xFF0077D4).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _sexo == 'masculino' ? const Color(0xFF0077D4) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Femenino'),
                      selected: _sexo == 'femenino',
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onSelected: (val) {
                        if (val) setState(() => _sexo = 'femenino');
                      },
                      selectedColor: const Color(0xFF0077D4).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _sexo == 'femenino' ? const Color(0xFF0077D4) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),

                // Edad
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edad (años)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: '$_edad',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: _inputDecoration('años'),
                        onChanged: (v) => _edad = int.tryParse(v) ?? _edad,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 12 || n > 100) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),

                // Peso
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Peso Corporal (kg)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: '$_pesoKg',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: _inputDecoration('kg'),
                        onChanged: (v) => _pesoKg = double.tryParse(v) ?? _pesoKg,
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 30 || n > 250) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),

                // Altura
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Altura (cm)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: '$_alturaCm',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: _inputDecoration('cm'),
                        onChanged: (v) => _alturaCm = double.tryParse(v) ?? _alturaCm,
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 100 || n > 250) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 2: ACTIVIDAD Y OBJETIVO
          _buildSectionTitle('2. OBJETIVO & ACTIVIDAD FÍSICA'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Objetivo Nutricional Principal',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _objetivo,
                  decoration: _selectDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'aumento_masa_muscular',
                      child: Text(
                        'Aumento de Masa Muscular (Hipertrofia)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'perdida_grasa',
                      child: Text(
                        'Pérdida de Grasa & Definición',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'mantenimiento',
                      child: Text(
                        'Mantenimiento & Salud General',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'definicion',
                      child: Text(
                        'Definición Muscular Extrema',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'rendimiento',
                      child: Text(
                        'Rendimiento Atlético / Fuerza',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _objetivo = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nivel de Actividad Física Habitual',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _nivelActividad,
                  decoration: _selectDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'sedentario',
                      child: Text(
                        'Sedentario (Poco o ningún ejercicio)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ligero',
                      child: Text(
                        'Ligero (1-2 días de entreno / semana)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'moderado',
                      child: Text(
                        'Moderado (3-5 días de entreno / semana)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'intenso',
                      child: Text(
                        'Intenso (6-7 días de entreno intenso)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'muy_intenso',
                      child: Text(
                        'Muy Intenso (Atleta de alto rendimiento)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _nivelActividad = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 3: FRECUENCIA Y PRESUPUESTO
          _buildSectionTitle('3. COMIDAS & PRESUPUESTO'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Comidas al día prescritas',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: [3, 4, 5, 6].map((numComidas) {
                        final isSel = _comidasAlDia == numComidas;
                        return InkWell(
                          onTap: () => setState(() => _comidasAlDia = numComidas),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 34,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF0077D4) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$numComidas',
                              style: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF334155),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),

                const Text(
                  'Presupuesto Culinario',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _presupuesto,
                  decoration: _selectDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'economico',
                      child: Text(
                        'Económico (Canasta básica universitaria accesible)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'estandar',
                      child: Text(
                        'Estándar (Variedad balanceada)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'flexible',
                      child: Text(
                        'Flexible / Premium (Cortes magros, suplementos)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _presupuesto = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 4: RESTRICCIONES Y GUSTOS
          _buildSectionTitle('4. ALERGIAS Y PREFERENCIAS (OPCIONAL)'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _restriccionesController,
                  decoration: _textFieldDecoration(
                    label: 'Alergias o restricciones médicas',
                    hint: 'ej: sin lactosa, celíaco, vegetariano',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alimentosEvitarController,
                  decoration: _textFieldDecoration(
                    label: 'Alimentos no deseados o que no te gusten',
                    hint: 'ej: pescado, cebolla, avena',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 2,
                  decoration: _textFieldDecoration(
                    label: 'Observaciones adicionales para la IA',
                    hint: 'ej: Tengo poco tiempo para cocinar en el almuerzo...',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Botón de Generar
          ElevatedButton.icon(
            onPressed: _ejecutarGeneracion,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: const Text(
              'Generar Plan Nutricional con IA',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077D4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadoView(
    RecomendacionNutricionalResponse rec,
    bool isSaving,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Success Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DISEÑADO POR GEMINI 2.5 FLASH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(generarPlanIaProvider.notifier).reset();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.refresh, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Recomendación Nutricional Lista',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${rec.caloriasDiariasRecomendadas} kcal/día • ${rec.comidas.length} comidas diarias estructuradas',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Balance de Macros
        MacrosSummaryWidget(
          calorias: rec.caloriasDiariasRecomendadas,
          proteinasG: rec.macronutrientesTotales.proteinasG,
          carbohidratosG: rec.macronutrientesTotales.carbohidratosG,
          grasasG: rec.macronutrientesTotales.grasasG,
          hidratacionLitros: rec.hidratacionRecomendadaLitros,
        ),

        const SizedBox(height: 14),

        // Resumen de Estrategia
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF0077D4), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'ESTRATEGIA CLÍNICA DE LA IA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0077D4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                rec.resumenEstrategia,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF1E3A8A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Consejos Clave
        if (rec.consejosClave.isNotEmpty) ...[
          _buildSectionTitle('CONSEJOS CLAVE DE ADHERENCIA'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: rec.consejosClave.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Lista de Comidas
        _buildSectionTitle('COMIDAS & RECETAS PRESCRITAS'),
        const SizedBox(height: 8),
        ...List.generate(rec.comidas.length, (idx) {
          final c = rec.comidas[idx];
          return ComidaDetailCard(
            index: idx,
            tipoComida: c.tipoComida,
            horarioSugerido: c.horarioSugerido,
            platoNombre: c.platoNombre,
            calorias: c.calorias,
            proteinasG: c.proteinasG,
            carbohidratosG: c.carbohidratosG,
            grasasG: c.grasasG,
            ingredientes: c.ingredientes,
            instruccionesPreparacion: c.instruccionesPreparacion,
            sustitutosAccesibles: c.sustitutosAccesibles,
            initialExpanded: idx == 0,
          );
        }),

        const SizedBox(height: 20),

        // Botón de Guardado Oficial
        ElevatedButton.icon(
          onPressed: isSaving ? null : _guardarPlanOficial,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save, size: 20),
          label: Text(
            isSaving ? 'Guardando en Base de Datos...' : 'Guardar como Plan Oficial',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 0.6,
      ),
    );
  }

  InputDecoration _inputDecoration(String suffix) {
    return InputDecoration(
      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    );
  }

  InputDecoration _selectDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    );
  }

  InputDecoration _textFieldDecoration({required String label, required String hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    );
  }
}
