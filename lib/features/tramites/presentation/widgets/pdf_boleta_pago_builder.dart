import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/boleta_pago_model.dart';

class PdfBoletaPagoBuilder {
  static Future<Uint8List> buildPdf(BoletaPagoModel boleta) async {
    final pdf = pw.Document();

    final fechaStr = boleta.fechaPago != null
        ? '${boleta.fechaPago!.day.toString().padLeft(2, '0')}/${boleta.fechaPago!.month.toString().padLeft(2, '0')}/${boleta.fechaPago!.year}'
        : 'Fecha no registrada';

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
                          'COMPLEJO DEPORTIVO & GIMNASIO UNIVERSITARIO',
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
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: PdfColors.blue300),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'COMPROBANTE',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            boleta.numeroBoleta,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Título del Documento
              pw.Center(
                child: pw.Text(
                  'BOLETA DE PAGO / ARANCEL UNIVERSITARIO',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Comprobante emitido por Sistema de Gestión Deportiva DUBSS-GYM',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                ),
              ),

              pw.SizedBox(height: 20),

              // Tabla de Detalles
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  _buildTableRow('Número de Comprobante:', boleta.numeroBoleta, isHeader: false),
                  _buildTableRow('Fecha de Emisión / Pago:', fechaStr, isHeader: false),
                  _buildTableRow('Titular / Beneficiario:', boleta.usuarioNombre ?? 'Socio Universitario', isHeader: false),
                  _buildTableRow('Concepto de Pago:', boleta.concepto, isHeader: false),
                  if (boleta.planNombre != null)
                    _buildTableRow('Plan Asignado:', boleta.planNombre!, isHeader: false),
                  if (boleta.disciplinaNombre != null)
                    _buildTableRow('Disciplina:', boleta.disciplinaNombre!, isHeader: false),
                  _buildTableRow('Método de Pago:', boleta.metodoPago, isHeader: false),
                  _buildTableRow('Estado de la Transacción:', boleta.estadoLabel, isHeader: false),
                ],
              ),

              pw.SizedBox(height: 20),

              // Cuadro de Total
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.blue300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL PAGADO:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Bs. ${boleta.monto.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // Sello y QR de Verificación
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'UAGRM-DUBSS-PAGO:${boleta.numeroBoleta}:${boleta.monto}',
                      width: 55,
                      height: 55,
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VERIFICACIÓN DIGITAL INSTITUCIONAL',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.Text(
                            'Este comprobante certifica la cancelación arancelaria conforme al reglamento de bienestar estudiantil de la UAGRM.',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Generado electrónicamente desde la aplicación oficial DUBSS-GYM',
                            style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500),
                          ),
                        ],
                      ),
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

  static pw.TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey100) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey900,
            ),
          ),
        ),
      ],
    );
  }
}
