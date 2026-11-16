import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../providers/rutina_timer_provider.dart';

class DescansoTimerDialog extends ConsumerWidget {
  final String ejercicioNombre;

  const DescansoTimerDialog({
    super.key,
    required this.ejercicioNombre,
  });

  static Future<void> show(
    BuildContext context, {
    required int segundos,
    required String ejercicioNombre,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DescansoTimerDialog(
        ejercicioNombre: ejercicioNombre,
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(descansoTimerProvider);
    final timerNotifier = ref.read(descansoTimerProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
      ),
      backgroundColor: AppColors.carbonSurface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.solarGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Temporizador de Descanso',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSlateMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Exercise name
            Text(
              ejercicioNombre,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSlateLight,
              ),
            ),
            const SizedBox(height: 24),

            // Circular Countdown Display
            SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: timerState.isFinished
                        ? 1.0
                        : (timerState.totalSeconds > 0
                            ? (timerState.remainingSeconds / timerState.totalSeconds)
                            : 0),
                    strokeWidth: 8,
                    backgroundColor: AppColors.carbonSurfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerState.isFinished
                          ? AppColors.successEmerald
                          : AppColors.accentVibrant,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timerState.isFinished) ...[
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.successEmerald,
                            size: 42,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '¡Listo!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.successLight,
                            ),
                          ),
                          const Text(
                            'Siguiente serie',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSlateMuted,
                            ),
                          ),
                        ] else ...[
                          Text(
                            _formatTime(timerState.remainingSeconds),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textWhite,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timerState.isRunning ? 'DESCANSANDO' : 'PAUSADO',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.solarGold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick add seconds row (+15s, +30s)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickAddButton(label: '+15s', onTap: () => timerNotifier.addSeconds(15)),
                const SizedBox(width: 8),
                _buildQuickAddButton(label: '+30s', onTap: () => timerNotifier.addSeconds(30)),
                const SizedBox(width: 8),
                _buildQuickAddButton(label: '+60s', onTap: () => timerNotifier.addSeconds(60)),
              ],
            ),
            const SizedBox(height: 20),

            // Control Buttons (Pause/Resume, Reset, Terminar)
            Row(
              children: [
                Expanded(
                  child: CrimsonButton(
                    onPressed: () {
                      if (timerState.isRunning) {
                        timerNotifier.pause();
                      } else {
                        timerNotifier.resume();
                      }
                    },
                    icon: Icon(
                      timerState.isRunning ? Icons.pause : Icons.play_arrow,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: timerState.isRunning ? 'Pausar' : 'Reanudar',
                    style: CrimsonButtonStyle.gradient,
                    height: 42,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CrimsonButton(
                    onPressed: () {
                      timerNotifier.stop();
                      Navigator.of(context).pop();
                    },
                    label: 'Listo',
                    style: CrimsonButtonStyle.outline,
                    height: 42,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.carbonSurfaceMuted,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.solarGold,
          ),
        ),
      ),
    );
  }
}
