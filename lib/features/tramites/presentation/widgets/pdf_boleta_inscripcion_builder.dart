import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/boleta_inscripcion_model.dart';

class PdfBoletaInscripcionBuilder {
  static Future<Uint8List> buildPdf(BoletaInscripcionModel boleta) async {
    final pdf = pw.Document();

    final fInicioStr = boleta.fechaInicio != null
        ? '${boleta.fechaInicio!.day.toString().padLeft(2, '0')}/${boleta.fechaInicio!.month.toString().padLeft(2, '0')}/${boleta.fechaInicio!.year}'
        : '-';

    final fFinStr = boleta.fechaFin != null
        ? '${boleta.fechaFin!.day.toString().padLeft(2, '0')}/${boleta.fechaFin!.month.toString().padLeft(2, '0')}/${boleta.fechaFin!.year}'
        : '-';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabecera Institucional
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue900, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'UNIVERSIDAD AUTÓNOMA GABRIEL RENÉ MORENO',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'DIRECCIÓN UNIVERSITARIA DE BIENESTAR SOCIAL Y SALUD (DUBSS)',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.Text(
                          'SISTEMA DE CONTROL DE ACCESO & MEMBRESÍAS DEPORTIVAS',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: PdfColors.green400),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'MEMBRESÍA ACTIVA',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green900,
                            ),
                          ),
                          pw.Text(
                            boleta.numeroBoleta,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // Título
              pw.Center(
                child: pw.Text(
                  'BOLETA OFICIAL DE INSCRIPCIÓN Y ACCESO AL GIMNASIO',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Credencial Deportiva Universitaria DUBSS-GYM',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                ),
              ),

              pw.SizedBox(height: 18),

              // Tabla de Datos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  _buildRow('N° de Inscripción:', boleta.numeroBoleta),
                  _buildRow('Estudiante / Titular:', boleta.usuarioNombre ?? 'Socio Universitario'),
                  if (boleta.usuarioRu != null && boleta.usuarioRu!.isNotEmpty)
                    _buildRow('Registro Universitario (R.U.):', boleta.usuarioRu!),
                  if (boleta.usuarioCi != null && boleta.usuarioCi!.isNotEmpty)
                    _buildRow('Cédula de Identidad (C.I.):', boleta.usuarioCi!),
                  _buildRow('Disciplina Deportiva:', boleta.disciplina),
                  _buildRow('Horario de Turno:', boleta.horarioFormateado),
                  _buildRow('Periodo de Vigencia:', '$fInicioStr al $fFinStr'),
                  _buildRow('Días Restantes de Acceso:', '${boleta.diasRestantes} días'),
                  _buildRow('Estado de la Membresía:', boleta.isActiva ? 'HABILITADO PARA INGRESO' : 'VENCIDO / INACTIVO'),
                  _buildRow('Monto Arancelario:', 'Bs. ${boleta.monto.toStringAsFixed(2)}'),
                ],
              ),

              pw.SizedBox(height: 20),

              // Tarjeta Central con Código QR para Escaneo
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'UAGRM-ACCESO:${boleta.id}:${boleta.numeroBoleta}:${boleta.idUsuario}',
                      width: 80,
                      height: 80,
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PASE QR DE ENTRADA Y SALIDA',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Presente este código QR en el lector óptico del torniquete del gimnasio para registrar automáticamente su ingreso y salida.',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Válido únicamente en el turno asignado y con matrícula vigente.',
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Pie de página institucional
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Dirección Universitaria de Bienestar Social y Salud - Campus UAGRM',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'Santa Cruz de la Sierra, Bolivia',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColors.grey900,
            ),
          ),
        ),
      ],
    );
  }
}
