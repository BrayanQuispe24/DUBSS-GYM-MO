import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documentos_provider.dart';

class DocumentoUploadSheet extends ConsumerStatefulWidget {
  const DocumentoUploadSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const DocumentoUploadSheet(),
      ),
    );
  }

  @override
  ConsumerState<DocumentoUploadSheet> createState() =>
      _DocumentoUploadSheetState();
}

class _DocumentoUploadSheetState extends ConsumerState<DocumentoUploadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();

  int? _selectedTipoId;
  PlatformFile? _selectedFile;
  int _fileSizeBytes = 0;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _errorMessage = null);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final size = (await file.length()) ?? file.lengthSync() ?? 0;

        // Validar tamaño máximo (10 MB = 10 * 1024 * 1024 bytes)
        if (size > 10 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'El archivo supera el tamaño máximo permitido de 10 MB.';
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileSizeBytes = size;
          // Si el título está vacío, sugerir el nombre del archivo sin extensión
          if (_tituloController.text.trim().isEmpty) {
            final rawName = file.name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
            _tituloController.text = rawName;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar el archivo: $e';
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTipoId == null) {
      setState(() => _errorMessage = 'Selecciona un tipo de documento.');
      return;
    }

    if (_selectedFile == null || _selectedFile!.path == null) {
      setState(() => _errorMessage = 'Por favor selecciona un archivo PDF.');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(documentosListProvider.notifier).uploadDocumento(
            idTipoDocumento: _selectedTipoId!,
            filePath: _selectedFile!.path!,
            fileName: _selectedFile!.name,
            titulo: _tituloController.text.trim().isNotEmpty
                ? _tituloController.text.trim()
                : null,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AppException: ', '');
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposDocumentosListProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF0077D4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subir Documento Digital',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Certificados, respaldos o carnets (PDF)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Campo: Tipo de Documento
                const Text(
                  'Tipo de Documento *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                tiposAsync.when(
                  data: (tipos) => DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _selectedTipoId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      hintText: 'Selecciona una categoría...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF003B70), width: 1.5),
                      ),
                    ),
                    items: tipos.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(
                          t.nombre,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedTipoId = val);
                    },
                    validator: (val) {
                      if (val == null) return 'Selecciona un tipo de documento';
                      return null;
                    },
                  ),
                  loading: () => const LinearProgressIndicator(
                    color: Color(0xFF003B70),
                  ),
                  error: (err, stack) => const Text(
                    'No se pudieron cargar los tipos de documento.',
                    style: TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo: Título
                const Text(
                  'Título / Descripción Breve',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Carnet de Identidad 2026, Certificado Médico',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF003B70), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Archivo PDF
                const Text(
                  'Archivo PDF (Máx. 10 MB) *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),

                if (_selectedFile == null)
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            size: 36,
                            color: Color(0xFF003B70),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca aquí para seleccionar un archivo PDF',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Solo formato .pdf (Hasta 10 MB)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Color(0xFFDC2626),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFile!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatFileSize(_fileSizeBytes)} • Listo para subir',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _pickFile,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF003B70),
                          ),
                          child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (_isUploading || _selectedFile == null)
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B70),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Subir Documento',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
