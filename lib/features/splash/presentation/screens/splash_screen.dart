import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
    _startAppInitialization();
  }

  void _startAppInitialization() {
    // Temporizador de 2 segundos para asegurar percepción de marca
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      final authState = ref.read(authNotifierProvider);

      if (authState.status == AuthStatus.authenticated) {
        if (authState.user?.isStaff ?? false) {
          context.go('/receptionist');
        } else {
          context.go('/client');
        }
      } else {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF0A0F1D),
              Color(0xFF030712),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Contenido Central Animado (Logo + Títulos)
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Contenedor del Emblema / Icono Institucional
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0077D4), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0077D4).withValues(alpha: 0.4),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Título Institucional
                      const Text(
                        'GIMNASIO UAGRM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtítulo D.U.B.S.S. System
                      const Text(
                        'D.U.B.S.S. SYSTEM',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Detalle Universitario
                      Text(
                        'Dirección Universitaria de Bienestar Social y Salud',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Indicador de Carga Sutil
                      SizedBox(
                        width: 130,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            backgroundColor: Color(0xFF1E293B),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077D4)),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pie de Página Institucional
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Text(
                      'UNIVERSIDAD AUTÓNOMA GABRIEL RENÉ MORENO',
                      style: TextStyle(
                        color: const Color(0xFF64748B).withValues(alpha: 0.8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Santa Cruz de la Sierra • Versión 1.0.0',
                      style: TextStyle(
                        color: const Color(0xFF475569).withValues(alpha: 0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
