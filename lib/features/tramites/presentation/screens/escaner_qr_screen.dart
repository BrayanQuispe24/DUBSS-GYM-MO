import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/datasources/tramites_remote_datasource.dart';
import '../widgets/resultado_acceso_dialog.dart';

class EscanerQRScreen extends ConsumerStatefulWidget {
  const EscanerQRScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const EscanerQRScreen()),
    );
  }

  @override
  ConsumerState<EscanerQRScreen> createState() => _EscanerQRScreenState();
}

class _EscanerQRScreenState extends ConsumerState<EscanerQRScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String _scanMode = 'auto'; // 'auto', 'entrada', 'salida'

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final ds = ref.read(tramitesRemoteDataSourceProvider);
      final resultado = await ds.validarQRAcceso(rawValue, tipo: _scanMode);

      if (!mounted) return;

      await ResultadoAccesoDialog.show(
        context,
        resultado,
        onDismiss: () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al validar código: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );

      // Pequeño retardo antes de reanudar el escáner
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Stream
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcodeDetected,
          ),

          // Viewfinder Overlay
          _buildViewfinderOverlay(),

          // Top Action Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Center Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Color(0xFF38BDF8), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Lector de Accesos DUBSS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flash & Camera controls
                  Row(
                    children: [
                      // Torch Toggle
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: _isTorchOn ? Colors.amber : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await _controller.toggleTorch();
                            if (mounted) {
                              setState(() => _isTorchOn = !_isTorchOn);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Switch Camera Facing
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 20),
                          onPressed: () => _controller.switchCamera(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar Controls (Mode Selection)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Verificando credencial de acceso...',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Enfoque el código QR dentro del recuadro para validar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ),

                  // Mode Selector Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeChip('auto', 'Automático', Icons.sync_alt),
                      const SizedBox(width: 8),
                      _buildModeChip('entrada', 'Entrada', Icons.login),
                      const SizedBox(width: 8),
                      _buildModeChip('salida', 'Salida', Icons.logout),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, String label, IconData icon) {
    final isSelected = _scanMode == mode;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _scanMode = mode);
      },
      selectedColor: const Color(0xFF0077D4),
      backgroundColor: Colors.black45,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF38BDF8) : Colors.white24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      showCheckmark: false,
    );
  }

  Widget _buildViewfinderOverlay() {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.72;

    return Center(
      child: Container(
        width: scanSize,
        height: scanSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isProcessing ? const Color(0xFFF59E0B) : const Color(0xFF0077D4),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isProcessing ? const Color(0xFFF59E0B) : const Color(0xFF0077D4))
                  .withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
