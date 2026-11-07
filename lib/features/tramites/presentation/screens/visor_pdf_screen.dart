import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class VisorPdfScreen extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() documentBuilder;

  const VisorPdfScreen({
    super.key,
    required this.title,
    required this.documentBuilder,
  });

  static void open(
    BuildContext context, {
    required String title,
    required Future<Uint8List> Function() documentBuilder,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => VisorPdfScreen(
          title: title,
          documentBuilder: documentBuilder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PdfPreview(
        build: (format) => documentBuilder(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0077D4)),
        ),
        pdfFileName: '${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf',
        actions: const [],
      ),
    );
  }
}
