import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/discipline_model.dart';
import '../../data/models/pricing_plan_model.dart';

/// Notifier para gestionar la categoría activa seleccionada
class ActiveCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setCategory(String category) {
    state = category;
  }
}

final activeCategoryProvider =
    NotifierProvider<ActiveCategoryNotifier, String>(ActiveCategoryNotifier.new);

/// Lista de disciplinas deportivas basadas en el catálogo real de UAGRM DUBS
final disciplinesProvider = Provider<List<DisciplineModel>>((ref) {
  final category = ref.watch(activeCategoryProvider);

  const allServices = [
    DisciplineModel(
      id: '1',
      title: 'Musculación (Aparatos)',
      category: 'aparatos',
      categoryLabel: 'Aparatos & Pesas',
      description: 'Área equipada con máquinas selectorizadas, racks de potencia, mancuernas olímpicas y zona cardio.',
      schedule: 'Lun - Sáb: 06:00 - 22:00',
      instructor: 'Coaches UAGRM de Turno',
      capacity: '80 personas simultáneas',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
      tags: ['Aparatos Selectorizados', 'Racks Olímpico', 'Cardio', 'Supervisión'],
      studentPrice: 'Bs. 50 / mes',
      docentPrice: 'Bs. 80 / mes',
    ),
    DisciplineModel(
      id: '2',
      title: 'Boxeo Universitario',
      category: 'boxeo',
      categoryLabel: 'Boxeo',
      description: 'Entrenamiento de técnica de puño, trabajo de sacos, manoplas, sparring supervisado y acondicionamiento.',
      schedule: 'Lun, Mié, Vie: 16:00 - 18:00 / 18:00 - 20:00',
      instructor: 'Entrenador Lic. Roberto Siles',
      capacity: '25 cupos por turno',
      imageUrl: 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?auto=format&fit=crop&w=800&q=80',
      tags: ['Ring Oficial', 'Sacos de Cuero', 'Pera Loca', 'Técnica'],
      studentPrice: 'Bs. 60 / mes',
      docentPrice: 'Bs. 90 / mes',
    ),
    DisciplineModel(
      id: '3',
      title: 'Kick Boxing',
      category: 'kickboxing',
      categoryLabel: 'Kick Boxing',
      description: 'Disciplina de combate que combina técnicas de boxeo y patadas. Alta quema calórica y defensa personal.',
      schedule: 'Mar, Jue, Sáb: 17:00 - 19:00',
      instructor: 'Coach Prof. Marco Aguilera',
      capacity: '20 cupos por turno',
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80',
      tags: ['Pats & Escudos', 'Resistencia', 'Combate', 'Coordinación'],
      studentPrice: 'Bs. 60 / mes',
      docentPrice: 'Bs. 90 / mes',
    ),
    DisciplineModel(
      id: '4',
      title: 'Baile & Ritmo Universitario',
      category: 'baile',
      categoryLabel: 'Baile & Zumba',
      description: 'Clases dinámicas de ritmoterapia, zumba, ritmos latinos y cardio dance para todas las edades.',
      schedule: 'Lun a Vie: 19:00 - 20:30',
      instructor: 'Inst. Valeria Vargas',
      capacity: '40 personas por sesión',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=800&q=80',
      tags: ['Zumba Fitness', 'Ritmos Latinos', 'Salón Espejado', 'Audio Pro'],
      studentPrice: 'Bs. 45 / mes',
      docentPrice: 'Bs. 75 / mes',
    ),
    DisciplineModel(
      id: '5',
      title: 'Entrenamiento Funcional',
      category: 'funcional',
      categoryLabel: 'Funcional & TRX',
      description: 'Rutinas de alta intensidad en circuitos con kettlebells, cuerdas de batalla, balones y TRX.',
      schedule: 'Lun a Sáb: 07:00 - 09:00 / 18:30 - 20:00',
      instructor: 'Lic. Fernando Gutiérrez',
      capacity: '30 cupos por turno',
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80',
      tags: ['Circuito HIIT', 'TRX Suspension', 'Kettlebells', 'Cuerdas'],
      studentPrice: 'Bs. 55 / mes',
      docentPrice: 'Bs. 85 / mes',
    ),
  ];

  if (category == 'all') return allServices;
  return allServices.where((s) => s.category == category).toList();
});

/// Lista de membresías y precios oficiales de la DUBS
final pricingPlansProvider = Provider<List<PricingPlanModel>>((ref) {
  return const [
    PricingPlanModel(
      id: 'estudiantes',
      title: 'Membresía Estudiantes',
      target: 'ALUMNOS REGULARES UAGRM',
      price: 'Bs. 50',
      period: '/ mes',
      description: 'Tarifa especial universitaria para estudiantes inscritos en cualquier carrera o facultad de la UAGRM.',
      highlight: '100% Subvencionada por Bienestar Social',
      features: [
        'Acceso ilimitado a Gimnasio & Aparatos',
        'Clases de Boxeo, Kick Boxing y Baile',
        'Circuitos de Entrenamiento Funcional',
        'Indicación de ejercicios por Instructores',
        'Carnet Digital & Control de Acceso QR',
      ],
      isPopular: true,
      buttonText: 'Inscribirme como Estudiante',
    ),
    PricingPlanModel(
      id: 'docentes',
      title: 'Membresía Administrativos & Docentes',
      target: 'PERSONAL INSTITUCIONAL',
      price: 'Bs. 80',
      period: '/ mes',
      description: 'Dirigida al cuerpo docente y personal administrativo que presta servicios en la UAGRM.',
      highlight: 'Descuento por Boleta de Pago Institucional',
      features: [
        'Acceso completo a todas las disciplinas',
        'Horarios extendidos de 06:00 a 22:00',
        'Lockers y casilleros preferenciales',
        'Plan de acondicionamiento con Instructores',
        'Validación de vigencia automática',
      ],
      isPopular: false,
      buttonText: 'Inscribirme como Docente / Admin',
    ),
    PricingPlanModel(
      id: 'pase-diario',
      title: 'Pase Diario Eventual',
      target: 'PASE POR SESIÓN',
      price: 'Bs. 10',
      period: '/ día',
      description: 'Acceso por una jornada para estudiantes o personal universitario sin membresía mensual activa.',
      highlight: 'Ideal para entrenamientos ocasionales',
      features: [
        'Entrada por el día completo',
        'Acceso libre a la sala de Aparatos',
        'Participación en la clase del día',
        'Orientación básica por Instructor',
        'Registro de ingreso en recepción',
      ],
      isPopular: false,
      buttonText: 'Comprar Pase Diario',
    ),
  ];
});
