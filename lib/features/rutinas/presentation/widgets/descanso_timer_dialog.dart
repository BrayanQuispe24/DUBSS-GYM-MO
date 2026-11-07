import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rutina_timer_provider.dart';

class DescansoTimerDialog extends ConsumerWidget {
  final int segundosIniciales;
  final String ejercicioNombre;

  const DescansoTimerDialog({
    super.key,
    required this.segundosIniciales,
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
        segundosIniciales: segundos,
        ejercicioNombre: ejercicioNombre,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(descansoTimerProvider);
    final timerNotifier = ref.read(descansoTimerProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 8,
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
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Temporizador de Descanso',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
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
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // Circular Countdown Display
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: timerState.isFinished
                        ? 1.0
                        : (timerState.totalSeconds > 0
                            ? (timerState.remainingSeconds / timerState.totalSeconds)
                            : 0),
                    strokeWidth: 9,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerState.isFinished
                          ? const Color(0xFF10B981)
                          : const Color(0xFF0077D4),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timerState.isFinished) ...[
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF10B981),
                            size: 42,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '¡Listo!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const Text(
                            'Siguiente serie',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          Text(
                            timerState.formattedTime,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            timerState.isRunning ? 'Descansando...' : 'En pausa',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: timerState.isRunning
                                  ? const Color(0xFF0077D4)
                                  : const Color(0xFF94A3B8),
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

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset / Restart
                IconButton.filledTonal(
                  onPressed: () {
                    timerNotifier.start(segundosIniciales);
                  },
                  icon: const Icon(Icons.replay, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF334155),
                  ),
                  tooltip: 'Reiniciar',
                ),
                const SizedBox(width: 14),

                // Main Play/Pause Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (timerState.isFinished) {
                      timerNotifier.start(segundosIniciales);
                    } else if (timerState.isRunning) {
                      timerNotifier.pause();
                    } else {
                      if (timerState.remainingSeconds <= 0) {
                        timerNotifier.start(segundosIniciales);
                      } else {
                        timerNotifier.resume();
                      }
                    }
                  },
                  icon: Icon(
                    timerState.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 22,
                  ),
                  label: Text(
                    timerState.isFinished
                        ? 'Repetir'
                        : (timerState.isRunning ? 'Pausar' : 'Iniciar'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 14),

                // +15 Seconds Button
                OutlinedButton(
                  onPressed: () {
                    timerNotifier.addSeconds(15);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    side: const BorderSide(color: Color(0xFFBAE6FD)),
                    backgroundColor: const Color(0xFFF0F9FF),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    '+15s',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
