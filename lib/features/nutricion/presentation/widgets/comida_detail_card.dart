import 'package:flutter/material.dart';

class ComidaDetailCard extends StatefulWidget {
  final int index;
  final String tipoComida;
  final String horarioSugerido;
  final String platoNombre;
  final int calorias;
  final double proteinasG;
  final double carbohidratosG;
  final double grasasG;
  final List<String> ingredientes;
  final String? instruccionesPreparacion;
  final List<String> sustitutosAccesibles;
  final bool initialExpanded;

  const ComidaDetailCard({
    super.key,
    required this.index,
    required this.tipoComida,
    required this.horarioSugerido,
    required this.platoNombre,
    required this.calorias,
    required this.proteinasG,
    required this.carbohidratosG,
    required this.grasasG,
    required this.ingredientes,
    this.instruccionesPreparacion,
    this.sustitutosAccesibles = const [],
    this.initialExpanded = false,
  });

  @override
  State<ComidaDetailCard> createState() => _ComidaDetailCardState();
}

class _ComidaDetailCardState extends State<ComidaDetailCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  Color _getTipoComidaColor(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('desayuno')) return const Color(0xFFF59E0B);
    if (t.contains('almuerzo')) return const Color(0xFF0077D4);
    if (t.contains('cena')) return const Color(0xFF8B5CF6);
    if (t.contains('merienda') || t.contains('media')) return const Color(0xFF10B981);
    return const Color(0xFF0284C7);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTipoComidaColor(widget.tipoComida);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded ? color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header clickable
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tipo de comida badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant, size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(
                              widget.tipoComida.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Horario & Calorie chip
                      Row(
                        children: [
                          if (widget.horarioSugerido.isNotEmpty) ...[
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 3),
                            Text(
                              widget.horarioSugerido,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 11, color: Color(0xFFDC2626)),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.calorias} kcal',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.platoNombre,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Macros pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildMacroBadge('P', '${widget.proteinasG.toStringAsFixed(0)}g', const Color(0xFF0077D4)),
                      _buildMacroBadge('C', '${widget.carbohidratosG.toStringAsFixed(0)}g', const Color(0xFFD97706)),
                      _buildMacroBadge('G', '${widget.grasasG.toStringAsFixed(0)}g', const Color(0xFF059669)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Collapsible detail body
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredientes
                  if (widget.ingredientes.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.kitchen,
                      color: const Color(0xFF0077D4),
                      title: 'INGREDIENTES Y PORCIONES',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.ingredientes.map((ing) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Color(0xFF0077D4),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ing,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF334155),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Preparación
                  if (widget.instruccionesPreparacion != null &&
                      widget.instruccionesPreparacion!.trim().isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.soup_kitchen_outlined,
                      color: const Color(0xFF16A34A),
                      title: 'INSTRUCCIONES DE PREPARACIÓN',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(
                        widget.instruccionesPreparacion!.trim(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF166534),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Sustitutos económicos
                  if (widget.sustitutosAccesibles.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.monetization_on_outlined,
                      color: const Color(0xFFD97706),
                      title: 'SUSTITUTOS ECONÓMICOS SUGERIDOS',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.sustitutosAccesibles.map((sus) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '⇄ ',
                                  style: TextStyle(
                                    color: Color(0xFFD97706),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    sus,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF92400E),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
