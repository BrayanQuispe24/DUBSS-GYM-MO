import 'package:flutter/material.dart';
import '../../data/models/antecedente_model.dart';

class AntecedentesViewWidget extends StatelessWidget {
  final AntecedenteModel? antecedente;
  final VoidCallback onEdit;

  const AntecedentesViewWidget({
    super.key,
    required this.antecedente,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ant = antecedente;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de estado general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (ant?.tieneAlgunaCondicionMedica ?? false)
                  ? const Color(0xFFEF4444).withAlpha(25)
                  : const Color(0xFF10B981).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (ant?.tieneAlgunaCondicionMedica ?? false)
                    ? const Color(0xFFEF4444).withAlpha(80)
                    : const Color(0xFF10B981).withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (ant?.tieneAlgunaCondicionMedica ?? false)
                      ? Icons.warning_amber_rounded
                      : Icons.verified_user_rounded,
                  color: (ant?.tieneAlgunaCondicionMedica ?? false)
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (ant?.tieneAlgunaCondicionMedica ?? false)
                            ? 'Condiciones Médicas Reportadas'
                            : 'Sin Antecedentes de Riesgo',
                        style: TextStyle(
                          color: (ant?.tieneAlgunaCondicionMedica ?? false)
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (ant?.tieneAlgunaCondicionMedica ?? false)
                            ? 'Presentar certificado médico de aptitud física en los próximos 15 días.'
                            : 'Ficha médica en regla para el uso de equipos del gimnasio.',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón para actualizar cuestionario
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF262626),
              foregroundColor: const Color(0xFFF59E0B),
              side: const BorderSide(color: Color(0xFFF59E0B)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: const Text(
              'Actualizar Cuestionario de Salud',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjetas de condiciones médicas
          _buildConditionCard(
            title: 'Enfermedades Cardiovasculares',
            isPositive: ant?.tieneEnfermedadesCardiovasculares ?? false,
            detail: ant?.detalleEnfermedadesCardiovasculares,
            icon: Icons.monitor_heart_outlined,
          ),
          _buildConditionCard(
            title: 'Intervención Cardiovascular (Bypass, marcapasos)',
            isPositive: ant?.seRealizoIntervencionCardiovascular ?? false,
            detail: ant?.detalleIntervencionCardiovascular,
            icon: Icons.heart_broken_outlined,
          ),
          _buildConditionCard(
            title: 'Hipertensión Arterial',
            isPositive: ant?.tieneHipertensionArterial ?? false,
            detail: ant?.detalleHipertensionArterial,
            icon: Icons.speed_outlined,
          ),
          _buildConditionCard(
            title: 'Enfermedades Pulmonares / Asma',
            isPositive: ant?.tieneEnfermedadesPulmonares ?? false,
            detail: ant?.detalleEnfermedadesPulmonares,
            icon: Icons.air_rounded,
          ),
          _buildConditionCard(
            title: 'Diabetes',
            isPositive: ant?.tieneDiabetes ?? false,
            detail: ant?.detalleDiabetes,
            icon: Icons.bloodtype_outlined,
          ),
          _buildConditionCard(
            title: 'Enfermedades Osteoarticulares',
            isPositive: ant?.tieneEnfermedadesOsteoarticulares ?? false,
            detail: ant?.detalleEnfermedadesOsteoarticulares,
            icon: Icons.accessibility_new_rounded,
          ),
          _buildConditionCard(
            title: 'Enfermedades Neurológicas',
            isPositive: ant?.tieneEnfermedadesNeurologicas ?? false,
            detail: ant?.detalleEnfermedadesNeurologicas,
            icon: Icons.psychology_outlined,
          ),
          _buildConditionCard(
            title: 'Convulsiones / Epilepsia',
            isPositive: ant?.tieneConvulsiones ?? false,
            detail: ant?.detalleConvulsiones,
            icon: Icons.warning_amber_rounded,
          ),
          _buildConditionCard(
            title: 'Intervenciones Quirúrgicas previas',
            isPositive: ant?.tieneIntervencionQuirurgica ?? false,
            detail: ant?.detalleIntervencionQuirurgica,
            icon: Icons.medical_services_outlined,
          ),
          _buildConditionCard(
            title: 'Fracturas Óseas previas',
            isPositive: ant?.sufrioFracturasOseas ?? false,
            detail: ant?.detalleFracturasOseas,
            icon: Icons.healing_rounded,
          ),
          _buildConditionCard(
            title: 'Síntomas durante deporte (mareos/desmayos)',
            isPositive: ant?.sufrioAlgunSintomaDuranteDeporte ?? false,
            detail: ant?.detalleSintomasDuranteDeporte,
            icon: Icons.sports_gymnastics_rounded,
          ),
          _buildConditionCard(
            title: 'Lesiones articulares o musculares',
            isPositive: ant?.tieneLesiones ?? false,
            detail: ant?.detalleLesiones,
            icon: Icons.personal_injury_outlined,
          ),
          _buildConditionCard(
            title: 'Alergias Conocidas',
            isPositive: ant?.tieneAlergias ?? false,
            detail: ant?.detalleAlergias,
            icon: Icons.coronavirus_outlined,
          ),
          if (ant?.observaciones != null && ant!.observaciones!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observaciones adicionales',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ant.observaciones!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionCard({
    required String title,
    required bool isPositive,
    String? detail,
    required IconData icon,
  }) {
    final statusColor = isPositive ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPositive ? statusColor.withAlpha(90) : Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPositive ? 'SÍ' : 'NO',
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (isPositive && detail != null && detail.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Detalle: $detail',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
