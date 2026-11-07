import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DescansoTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isFinished;

  const DescansoTimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isFinished,
  });

  double get progress {
    if (totalSeconds <= 0) return 0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  String get formattedTime {
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  DescansoTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isFinished,
  }) {
    return DescansoTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class DescansoTimerNotifier extends Notifier<DescansoTimerState> {
  Timer? _timer;

  @override
  DescansoTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const DescansoTimerState(
      remainingSeconds: 60,
      totalSeconds: 60,
      isRunning: false,
      isFinished: false,
    );
  }

  void start(int seconds) {
    _timer?.cancel();
    state = DescansoTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      isFinished: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isFinished: true,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    if (state.remainingSeconds <= 0 || state.isRunning) return;

    state = state.copyWith(isRunning: true, isFinished: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isFinished: true,
        );
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = DescansoTimerState(
      remainingSeconds: state.totalSeconds,
      totalSeconds: state.totalSeconds,
      isRunning: false,
      isFinished: false,
    );
  }

  void addSeconds(int seconds) {
    final newRemaining = state.remainingSeconds + seconds;
    final newTotal = state.totalSeconds + seconds;
    state = state.copyWith(
      remainingSeconds: newRemaining,
      totalSeconds: newTotal,
      isFinished: false,
    );
  }
}

final descansoTimerProvider =
    NotifierProvider<DescansoTimerNotifier, DescansoTimerState>(
  DescansoTimerNotifier.new,
);
