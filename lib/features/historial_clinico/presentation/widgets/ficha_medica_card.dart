import 'package:flutter/material.dart';
import '../../data/models/ficha_medica_model.dart';

class FichaMedicaCard extends StatelessWidget {
  final FichaMedicaModel ficha;

  const FichaMedicaCard({
    super.key,
    required this.ficha,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Estado del certificado médico
        _buildCertificadoBanner(),
        const SizedBox(height: 16),
        // Datos clínicos generales
        _buildSectionCard(
          title: 'Datos Clínicos Básicos',
          icon: Icons.bloodtype_outlined,
          children: [
            _buildDataRow(
              'Grupo Sanguíneo y Factor RH',
              '${ficha.grupoSanguineo ?? "--"} ${ficha.factorRh ?? ""}'.trim(),
            ),
            const SizedBox(height: 10),
            _buildChipsSection('Alergias Conocidas', ficha.alergias, const Color(0xFFEF4444)),
            const SizedBox(height: 10),
            _buildChipsSection('Afecciones / Patologías', ficha.enfermedadesCronicas, const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _buildChipsSection('Lesiones Previas', ficha.lesionesPrevias, const Color(0xFF3B82F6)),
          ],
        ),
        const SizedBox(height: 16),
        // Contacto de Emergencia
        _buildSectionCard(
          title: 'Contacto de Emergencia',
          icon: Icons.contact_phone_outlined,
          children: [
            _buildDataRow('Nombre', ficha.contactoEmergenciaNombre ?? 'No registrado'),
            _buildDataRow('Parentesco', ficha.contactoEmergenciaParentesco ?? 'No registrado'),
            _buildDataRow('Teléfono', ficha.contactoEmergenciaTelefono ?? 'No registrado'),
          ],
        ),
        if (ficha.observacionesMedicas != null && ficha.observacionesMedicas!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Observaciones y Recomendaciones',
            icon: Icons.notes_rounded,
            children: [
              Text(
                ficha.observacionesMedicas!,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCertificadoBanner() {
    final vigente = ficha.isCertificadoVigente;
    final color = vigente ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              vigente ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vigente ? 'Certificado Médico Vigente' : 'Certificado Médico Vencido o Pendiente',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vigente
                      ? 'Apto para realizar actividades físicas y uso de máquinas.'
                      : 'Por favor, renueva tu certificado en el consultorio médico.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChipsSection(String title, List<String> items, Color chipColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Text('Ninguna registrada', style: TextStyle(color: Colors.white38, fontSize: 13))
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chipColor.withAlpha(70)),
                ),
                child: Text(
                  item,
                  style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
