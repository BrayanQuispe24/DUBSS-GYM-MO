import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/documento_model.dart';

class DocumentoPreviewScreen extends ConsumerStatefulWidget {
  final DocumentoModel documento;

  const DocumentoPreviewScreen({
    super.key,
    required this.documento,
  });

  static void open(BuildContext context, DocumentoModel documento) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => DocumentoPreviewScreen(documento: documento),
      ),
    );
  }

  @override
  ConsumerState<DocumentoPreviewScreen> createState() =>
      _DocumentoPreviewScreenState();
}

class _DocumentoPreviewScreenState
    extends ConsumerState<DocumentoPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.documento.isPdf) {
      _fetchPdfBytes();
    }
  }

  Future<void> _fetchPdfBytes() async {
    setState(() {
      _isLoadingPdf = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioClientProvider);
      final url = widget.documento.fullFileUrl;

      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data != null) {
        if (mounted) {
          setState(() {
            _pdfBytes = Uint8List.fromList(response.data!);
            _isLoadingPdf = false;
          });
        }
      } else {
        throw Exception('El servidor no retornó datos del archivo.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo cargar el archivo PDF: $e';
          _isLoadingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.documento;
    final isPdf = doc.isPdf;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              doc.displayTipoNombre,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0B1727),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isPdf ? _buildPdfBody() : _buildImageBody(),
    );
  }

  Widget _buildPdfBody() {
    if (_isLoadingPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0077D4)),
            SizedBox(height: 16),
            Text(
              'Descargando documento...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchPdfBytes,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077D4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_pdfBytes == null) {
      return const Center(
        child: Text(
          'Documento no disponible.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return PdfPreview(
      build: (format) async => _pdfBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      maxPageWidth: 700,
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0077D4)),
      ),
      pdfFileName: '${docSafeName(widget.documento.displayTitle)}.pdf',
      actions: const [],
    );
  }

  Widget _buildImageBody() {
    final url = widget.documento.fullFileUrl;
    if (url.isEmpty) {
      return const Center(
        child: Text(
          'URL de imagen inválida',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.8,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, _) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0077D4)),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                SizedBox(height: 12),
                Text(
                  'No se pudo cargar la imagen',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String docSafeName(String title) {
    return title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
  }
}
