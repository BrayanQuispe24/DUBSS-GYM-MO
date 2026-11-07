import 'package:flutter/material.dart';
import '../../data/models/evaluacion_antropometrica_model.dart';

class EvaluacionDetalleCard extends StatelessWidget {
  final EvaluacionAntropometricaModel evaluacion;

  const EvaluacionDetalleCard({
    super.key,
    required this.evaluacion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card de Bioimpedancia
        _buildSectionCard(
          title: 'Bioimpedancia y Composición',
          icon: Icons.pie_chart_outline_rounded,
          children: [
            _buildDataRow('Grasa Corporal Total', '${evaluacion.porcentajeGrasa ?? "--"} %'),
            _buildDataRow('Masa Muscular Esquelética', '${evaluacion.porcentajeMusculo ?? "--"} %'),
            _buildDataRow('Masa Muscular (Kg)', '${evaluacion.masaMuscularKg ?? "--"} kg'),
            _buildDataRow('Nivel de Grasa Visceral', '${evaluacion.grasaVisceral ?? "--"}'),
            _buildDataRow('Agua Corporal Total', '${evaluacion.porcentajeAgua ?? "--"} %'),
          ],
        ),
        const SizedBox(height: 16),
        // Card de Perímetros Corporales
        _buildSectionCard(
          title: 'Perímetros Corporales (cm)',
          icon: Icons.straighten_rounded,
          children: [
            _buildDataRow('Cintura', '${evaluacion.perimetroCintura ?? "--"} cm'),
            _buildDataRow('Cadera', '${evaluacion.perimetroCadera ?? "--"} cm'),
            _buildDataRow('Pecho / Tórax', '${evaluacion.perimetroPecho ?? "--"} cm'),
            _buildDataRow('Brazo Relajado', '${evaluacion.perimetroBrazoRelajado ?? "--"} cm'),
            _buildDataRow('Brazo Contraído', '${evaluacion.perimetroBrazoContraido ?? "--"} cm'),
            _buildDataRow('Muslo Medio', '${evaluacion.perimetroMuslo ?? "--"} cm'),
            _buildDataRow('Pantorrilla', '${evaluacion.perimetroPantorrilla ?? "--"} cm'),
          ],
        ),
        const SizedBox(height: 16),
        // Card de Signos Vitales y Evaluador
        _buildSectionCard(
          title: 'Signos Vitales y Dictamen',
          icon: Icons.monitor_heart_outlined,
          children: [
            _buildDataRow(
              'Presión Arterial',
              (evaluacion.presionSistolica != null && evaluacion.presionDiastolica != null)
                  ? '${evaluacion.presionSistolica}/${evaluacion.presionDiastolica} mmHg'
                  : '--',
            ),
            _buildDataRow(
              'Frecuencia Cardíaca',
              evaluacion.frecuenciaCardiaca != null ? '${evaluacion.frecuenciaCardiaca} lpm' : '--',
            ),
            if (evaluacion.evaluadorNombre != null)
              _buildDataRow('Evaluador / Médico', evaluacion.evaluadorNombre!),
            if (evaluacion.observaciones != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  evaluacion.observaciones!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
