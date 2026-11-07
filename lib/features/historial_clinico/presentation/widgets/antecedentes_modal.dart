import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/antecedente_model.dart';
import '../providers/historial_clinico_notifier.dart';

class AntecedentesModal extends ConsumerStatefulWidget {
  final AntecedenteModel? antecedenteInicial;

  const AntecedentesModal({
    super.key,
    this.antecedenteInicial,
  });

  static Future<bool?> show(BuildContext context, {AntecedenteModel? antecedenteInicial}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AntecedentesModal(antecedenteInicial: antecedenteInicial),
    );
  }

  @override
  ConsumerState<AntecedentesModal> createState() => _AntecedentesModalState();
}

class _AntecedentesModalState extends ConsumerState<AntecedentesModal> {
  late bool _tieneCardio;
  late final TextEditingController _detCardioCtrl;

  late bool _tieneHipertension;
  late final TextEditingController _detHipertensionCtrl;

  late bool _tienePulmonar;
  late final TextEditingController _detPulmonarCtrl;

  late bool _tieneDiabetes;
  late final TextEditingController _detDiabetesCtrl;

  late bool _tieneOsteoarticular;
  late final TextEditingController _detOsteoarticularCtrl;

  late bool _tieneNeurologica;
  late final TextEditingController _detNeurologicaCtrl;

  late bool _tieneConvulsiones;
  late final TextEditingController _detConvulsionesCtrl;

  late bool _tieneCirugia;
  late final TextEditingController _detCirugiaCtrl;

  late bool _tieneFracturas;
  late final TextEditingController _detFracturasCtrl;

  late bool _tieneSintomasDeporte;
  late final TextEditingController _detSintomasDeporteCtrl;

  late bool _tieneLesiones;
  late final TextEditingController _detLesionesCtrl;

  late bool _tieneAlergias;
  late final TextEditingController _detAlergiasCtrl;

  late final TextEditingController _observacionesCtrl;

  @override
  void initState() {
    super.initState();
    final ant = widget.antecedenteInicial;

    _tieneCardio = ant?.tieneEnfermedadesCardiovasculares ?? false;
    _detCardioCtrl = TextEditingController(text: ant?.detalleEnfermedadesCardiovasculares ?? '');

    _tieneHipertension = ant?.tieneHipertensionArterial ?? false;
    _detHipertensionCtrl = TextEditingController(text: ant?.detalleHipertensionArterial ?? '');

    _tienePulmonar = ant?.tieneEnfermedadesPulmonares ?? false;
    _detPulmonarCtrl = TextEditingController(text: ant?.detalleEnfermedadesPulmonares ?? '');

    _tieneDiabetes = ant?.tieneDiabetes ?? false;
    _detDiabetesCtrl = TextEditingController(text: ant?.detalleDiabetes ?? '');

    _tieneOsteoarticular = ant?.tieneEnfermedadesOsteoarticulares ?? false;
    _detOsteoarticularCtrl = TextEditingController(text: ant?.detalleEnfermedadesOsteoarticulares ?? '');

    _tieneNeurologica = ant?.tieneEnfermedadesNeurologicas ?? false;
    _detNeurologicaCtrl = TextEditingController(text: ant?.detalleEnfermedadesNeurologicas ?? '');

    _tieneConvulsiones = ant?.tieneConvulsiones ?? false;
    _detConvulsionesCtrl = TextEditingController(text: ant?.detalleConvulsiones ?? '');

    _tieneCirugia = ant?.tieneIntervencionQuirurgica ?? false;
    _detCirugiaCtrl = TextEditingController(text: ant?.detalleIntervencionQuirurgica ?? '');

    _tieneFracturas = ant?.sufrioFracturasOseas ?? false;
    _detFracturasCtrl = TextEditingController(text: ant?.detalleFracturasOseas ?? '');

    _tieneSintomasDeporte = ant?.sufrioAlgunSintomaDuranteDeporte ?? false;
    _detSintomasDeporteCtrl = TextEditingController(text: ant?.detalleSintomasDuranteDeporte ?? '');

    _tieneLesiones = ant?.tieneLesiones ?? false;
    _detLesionesCtrl = TextEditingController(text: ant?.detalleLesiones ?? '');

    _tieneAlergias = ant?.tieneAlergias ?? false;
    _detAlergiasCtrl = TextEditingController(text: ant?.detalleAlergias ?? '');

    _observacionesCtrl = TextEditingController(text: ant?.observaciones ?? '');
  }

  @override
  void dispose() {
    _detCardioCtrl.dispose();
    _detHipertensionCtrl.dispose();
    _detPulmonarCtrl.dispose();
    _detDiabetesCtrl.dispose();
    _detOsteoarticularCtrl.dispose();
    _detNeurologicaCtrl.dispose();
    _detConvulsionesCtrl.dispose();
    _detCirugiaCtrl.dispose();
    _detFracturasCtrl.dispose();
    _detSintomasDeporteCtrl.dispose();
    _detLesionesCtrl.dispose();
    _detAlergiasCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final payload = {
      'tiene_enfermedades_cardiovasculares': _tieneCardio,
      if (_tieneCardio && _detCardioCtrl.text.trim().isNotEmpty)
        'detalle_enfermedades_cardiovasculares': _detCardioCtrl.text.trim(),
      'tiene_hipertension_arterial': _tieneHipertension,
      if (_tieneHipertension && _detHipertensionCtrl.text.trim().isNotEmpty)
        'detalle_hipertension_arterial': _detHipertensionCtrl.text.trim(),
      'tiene_enfermedades_pulmonares': _tienePulmonar,
      if (_tienePulmonar && _detPulmonarCtrl.text.trim().isNotEmpty)
        'detalle_enfermedades_pulmonares': _detPulmonarCtrl.text.trim(),
      'tiene_diabetes': _tieneDiabetes,
      if (_tieneDiabetes && _detDiabetesCtrl.text.trim().isNotEmpty)
        'detalle_diabetes': _detDiabetesCtrl.text.trim(),
      'tiene_enfermedades_osteoarticulares': _tieneOsteoarticular,
      if (_tieneOsteoarticular && _detOsteoarticularCtrl.text.trim().isNotEmpty)
        'detalle_enfermedades_osteoarticulares': _detOsteoarticularCtrl.text.trim(),
      'tiene_enfermedades_neurologicas': _tieneNeurologica,
      if (_tieneNeurologica && _detNeurologicaCtrl.text.trim().isNotEmpty)
        'detalle_enfermedades_neurologicas': _detNeurologicaCtrl.text.trim(),
      'tiene_convulsiones': _tieneConvulsiones,
      if (_tieneConvulsiones && _detConvulsionesCtrl.text.trim().isNotEmpty)
        'detalle_convulsiones': _detConvulsionesCtrl.text.trim(),
      'tiene_intervencion_quirurgica': _tieneCirugia,
      if (_tieneCirugia && _detCirugiaCtrl.text.trim().isNotEmpty)
        'detalle_intervencion_quirurgica': _detCirugiaCtrl.text.trim(),
      'sufrio_fracturas_oseas': _tieneFracturas,
      if (_tieneFracturas && _detFracturasCtrl.text.trim().isNotEmpty)
        'detalle_fracturas_oseas': _detFracturasCtrl.text.trim(),
      'sufrio_algun_sintoma_durante_deporte': _tieneSintomasDeporte,
      if (_tieneSintomasDeporte && _detSintomasDeporteCtrl.text.trim().isNotEmpty)
        'detalle_sintomas_durante_deporte': _detSintomasDeporteCtrl.text.trim(),
      'tiene_lesiones': _tieneLesiones,
      if (_tieneLesiones && _detLesionesCtrl.text.trim().isNotEmpty)
        'detalle_lesiones': _detLesionesCtrl.text.trim(),
      'tiene_alergias': _tieneAlergias,
      if (_tieneAlergias && _detAlergiasCtrl.text.trim().isNotEmpty)
        'detalle_alergias': _detAlergiasCtrl.text.trim(),
      'observaciones': _observacionesCtrl.text.trim(),
    };

    final success = await ref
        .read(historialClinicoNotifierProvider.notifier)
        .guardarAntecedentes(payload);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antecedentes médicos actualizados con éxito'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        final err = ref.read(historialClinicoNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Error al guardar los antecedentes'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(historialClinicoNotifierProvider).isSubmitting;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.health_and_safety_outlined, color: Color(0xFFEF4444), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Cuestionario de Salud DUBSS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Marca las condiciones médicas y especifica los detalles requeridos por el médico evaluador.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildQuestionItem(
                    title: 'Enfermedades Cardiovasculares',
                    value: _tieneCardio,
                    onChanged: (v) => setState(() => _tieneCardio = v),
                    controller: _detCardioCtrl,
                    hint: 'Especifique afección o antecedente cardiovascular',
                  ),
                  _buildQuestionItem(
                    title: 'Hipertensión Arterial',
                    value: _tieneHipertension,
                    onChanged: (v) => setState(() => _tieneHipertension = v),
                    controller: _detHipertensionCtrl,
                    hint: 'Especifique medicación o estadio',
                  ),
                  _buildQuestionItem(
                    title: 'Enfermedades Pulmonares / Asma',
                    value: _tienePulmonar,
                    onChanged: (v) => setState(() => _tienePulmonar = v),
                    controller: _detPulmonarCtrl,
                    hint: 'Especifique asma, EPOC, etc.',
                  ),
                  _buildQuestionItem(
                    title: 'Diabetes',
                    value: _tieneDiabetes,
                    onChanged: (v) => setState(() => _tieneDiabetes = v),
                    controller: _detDiabetesCtrl,
                    hint: 'Especifique tipo de diabetes (1 o 2)',
                  ),
                  _buildQuestionItem(
                    title: 'Enfermedades Osteoarticulares',
                    value: _tieneOsteoarticular,
                    onChanged: (v) => setState(() => _tieneOsteoarticular = v),
                    controller: _detOsteoarticularCtrl,
                    hint: 'Artritis, artrosis, escoliosis, etc.',
                  ),
                  _buildQuestionItem(
                    title: 'Enfermedades Neurológicas',
                    value: _tieneNeurologica,
                    onChanged: (v) => setState(() => _tieneNeurologica = v),
                    controller: _detNeurologicaCtrl,
                    hint: 'Especifique patología neurológica',
                  ),
                  _buildQuestionItem(
                    title: 'Convulsiones / Epilepsia',
                    value: _tieneConvulsiones,
                    onChanged: (v) => setState(() => _tieneConvulsiones = v),
                    controller: _detConvulsionesCtrl,
                    hint: 'Frecuencia o última crisis',
                  ),
                  _buildQuestionItem(
                    title: 'Intervención Quirúrgica previa',
                    value: _tieneCirugia,
                    onChanged: (v) => setState(() => _tieneCirugia = v),
                    controller: _detCirugiaCtrl,
                    hint: 'Tipo de cirugía y fecha aproximada',
                  ),
                  _buildQuestionItem(
                    title: 'Fracturas Óseas previas',
                    value: _tieneFracturas,
                    onChanged: (v) => setState(() => _tieneFracturas = v),
                    controller: _detFracturasCtrl,
                    hint: 'Huesos afectados y secuelas',
                  ),
                  _buildQuestionItem(
                    title: 'Síntomas durante deporte (mareos/desmayos)',
                    value: _tieneSintomasDeporte,
                    onChanged: (v) => setState(() => _tieneSintomasDeporte = v),
                    controller: _detSintomasDeporteCtrl,
                    hint: 'Describa el síntoma ocurrido',
                  ),
                  _buildQuestionItem(
                    title: 'Lesiones articulares o musculares actuales',
                    value: _tieneLesiones,
                    onChanged: (v) => setState(() => _tieneLesiones = v),
                    controller: _detLesionesCtrl,
                    hint: 'Tendinitis, desgarros, esguinces...',
                  ),
                  _buildQuestionItem(
                    title: 'Alergias Conocidas',
                    value: _tieneAlergias,
                    onChanged: (v) => setState(() => _tieneAlergias = v),
                    controller: _detAlergiasCtrl,
                    hint: 'A medicamentos, alimentos o sustancias',
                  ),
                  const SizedBox(height: 12),
                  // Observaciones generales
                  TextField(
                    controller: _observacionesCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Observaciones generales del socio',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Cualquier detalle clínico adicional...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Guardar Cuestionario Médico',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFFEF4444).withAlpha(120) : Colors.white.withAlpha(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: value ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: value ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: const Color(0xFFEF4444),
                onChanged: onChanged,
              ),
            ],
          ),
          if (value) ...[
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withAlpha(30)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
