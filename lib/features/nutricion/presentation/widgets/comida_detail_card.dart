import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    if (t.contains('desayuno')) return AppColors.solarGold;
    if (t.contains('almuerzo')) return AppColors.accentVibrant;
    if (t.contains('cena')) return AppColors.solarAmber;
    if (t.contains('merienda') || t.contains('media')) return AppColors.successEmerald;
    return AppColors.accentVibrant;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTipoComidaColor(widget.tipoComida);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _expanded ? color : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header clickable
          InkWell(
            borderRadius: BorderRadius.circular(4),
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
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: color),
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
                            const Icon(Icons.access_time, size: 12, color: AppColors.textSlateMuted),
                            const SizedBox(width: 3),
                            Text(
                              widget.horarioSugerido,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSlateLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentVibrant.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentVibrant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 11, color: AppColors.accentVibrant),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.calorias} kcal',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentVibrant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.textSlateMuted,
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
                      color: AppColors.textWhite,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Macros pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildMacroBadge('P', '${widget.proteinasG.toStringAsFixed(0)}g', AppColors.primaryCrimson),
                      _buildMacroBadge('C', '${widget.carbohidratosG.toStringAsFixed(0)}g', AppColors.solarGold),
                      _buildMacroBadge('G', '${widget.grasasG.toStringAsFixed(0)}g', AppColors.successLight),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Collapsible detail body
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredientes
                  if (widget.ingredientes.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.kitchen,
                      color: AppColors.solarGold,
                      title: 'INGREDIENTES Y PORCIONES',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
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
                                    color: AppColors.accentVibrant,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ing,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSlateLight,
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
                      color: AppColors.successLight,
                      title: 'INSTRUCCIONES DE PREPARACIÓN',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        widget.instruccionesPreparacion!.trim(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSlateLight,
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
                      color: AppColors.solarAmber,
                      title: 'SUSTITUTOS ECONÓMICOS SUGERIDOS',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
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
                                    color: AppColors.solarAmber,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    sus,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSlateLight,
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
              color: AppColors.textSlateLight,
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
