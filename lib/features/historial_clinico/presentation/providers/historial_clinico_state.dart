import '../../data/models/historial_model.dart';

enum HistorialClinicoStatus { initial, loading, loaded, error }

class HistorialClinicoState {
  final HistorialClinicoStatus status;
  final List<HistorialModel> historiales;
  final HistorialModel? selectedHistorial;
  final String? errorMessage;
  final bool isSubmitting;
  final int selectedTabIndex;

  const HistorialClinicoState({
    this.status = HistorialClinicoStatus.initial,
    this.historiales = const [],
    this.selectedHistorial,
    this.errorMessage,
    this.isSubmitting = false,
    this.selectedTabIndex = 0,
  });

  bool get isLoading => status == HistorialClinicoStatus.loading;
  bool get isLoaded => status == HistorialClinicoStatus.loaded;
  bool get hasError => status == HistorialClinicoStatus.error;

  HistorialClinicoState copyWith({
    HistorialClinicoStatus? status,
    List<HistorialModel>? historiales,
    HistorialModel? selectedHistorial,
    String? errorMessage,
    bool? isSubmitting,
    int? selectedTabIndex,
    bool clearError = false,
  }) {
    return HistorialClinicoState(
      status: status ?? this.status,
      historiales: historiales ?? this.historiales,
      selectedHistorial: selectedHistorial ?? this.selectedHistorial,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
