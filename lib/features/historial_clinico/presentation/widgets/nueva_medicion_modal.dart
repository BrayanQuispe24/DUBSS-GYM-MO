import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/historial_clinico_notifier.dart';

class NuevaMedicionModal extends ConsumerStatefulWidget {
  const NuevaMedicionModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NuevaMedicionModal(),
    );
  }

  @override
  ConsumerState<NuevaMedicionModal> createState() => _NuevaMedicionModalState();
}

class _NuevaMedicionModalState extends ConsumerState<NuevaMedicionModal> {
  final _formKey = GlobalKey<FormState>();

  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _grasaController = TextEditingController();
  final _musculoController = TextEditingController();
  final _presionController = TextEditingController();
  late DateTime _fechaRegistro;

  double? _imcCalculado;

  @override
  void initState() {
    super.initState();
    _fechaRegistro = DateTime.now();
    _pesoController.addListener(_calcularImc);
    _alturaController.addListener(_calcularImc);
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _grasaController.dispose();
    _musculoController.dispose();
    _presionController.dispose();
    super.dispose();
  }

  void _calcularImc() {
    final peso = double.tryParse(_pesoController.text.trim());
    final alturaRaw = double.tryParse(_alturaController.text.trim());

    if (peso != null && alturaRaw != null && alturaRaw > 0) {
      final alturaM = alturaRaw > 3.0 ? alturaRaw / 100.0 : alturaRaw;
      final imc = peso / (alturaM * alturaM);
      setState(() {
        _imcCalculado = double.parse(imc.toStringAsFixed(1));
      });
    } else {
      if (_imcCalculado != null) {
        setState(() {
          _imcCalculado = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final peso = double.tryParse(_pesoController.text.trim());
    final altura = double.tryParse(_alturaController.text.trim());
    final grasa = double.tryParse(_grasaController.text.trim());
    final musculo = double.tryParse(_musculoController.text.trim());
    final presion = _presionController.text.trim();
    final fechaStr = _fechaRegistro.toIso8601String().split('T')[0];

    final success = await ref
        .read(historialClinicoNotifierProvider.notifier)
        .registrarMedicion(
          peso: peso,
          altura: altura,
          imc: _imcCalculado,
          porcentajeGrasa: grasa,
          masaMuscular: musculo,
          presion: presion.isNotEmpty ? presion : null,
          fechaRegistro: fechaStr,
        );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medición física registrada exitosamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        final error = ref.read(historialClinicoNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al guardar la medición'),
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
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de agarre
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

              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.monitor_weight_outlined, color: Color(0xFFF59E0B), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Registrar Medición Física',
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
              const SizedBox(height: 16),

              // Fecha de la medición
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fecha de registro:', style: TextStyle(color: Colors.white70)),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      backgroundColor: Colors.white.withAlpha(10),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaRegistro,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) {
                        setState(() => _fechaRegistro = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: Text(
                      '${_fechaRegistro.day}/${_fechaRegistro.month}/${_fechaRegistro.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Campos Peso y Altura
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _pesoController,
                      label: 'Peso (kg)',
                      hint: 'Ej: 72.5',
                      icon: Icons.scale_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _alturaController,
                      label: 'Altura (cm)',
                      hint: 'Ej: 175',
                      icon: Icons.height_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card de IMC Calculado en vivo
              if (_imcCalculado != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'IMC Calculado Automáticamente:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '$_imcCalculado',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Campos Bioimpedancia: % Grasa y Masa Muscular
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _grasaController,
                      label: '% Grasa Corporal',
                      hint: 'Ej: 18.2',
                      icon: Icons.pie_chart_outline,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _musculoController,
                      label: 'Masa Muscular (%)',
                      hint: 'Ej: 41.5',
                      icon: Icons.fitness_center_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Presión Arterial
              _buildTextField(
                controller: _presionController,
                label: 'Presión Arterial (mmHg)',
                hint: 'Ej: 120/80',
                icon: Icons.favorite_border_rounded,
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text(
                        'Guardar Medición',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFF59E0B), size: 18),
        filled: true,
        fillColor: const Color(0xFF262626),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF59E0B)),
        ),
      ),
    );
  }
}
