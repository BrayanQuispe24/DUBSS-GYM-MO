import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/historial_model.dart';

class PdfHistorialDubssBuilder {
  static Future<Uint8List> buildPdf(HistorialModel historial) async {
    final pdf = pw.Document();

    final nombreCompleto = historial.usuarioNombreCompleto;
    final ci = historial.usuarioCi.isNotEmpty ? historial.usuarioCi : '________________';
    final ru = historial.usuarioRegistro.isNotEmpty ? historial.usuarioRegistro : '________________';
    final email = historial.usuarioEmail.isNotEmpty ? historial.usuarioEmail : '________________';
    final celular = historial.usuarioCelular.isNotEmpty ? historial.usuarioCelular : '________________';

    final latestDetalle = historial.ultimaMedicion;
    final ant = historial.ultimoAntecedente;

    String formatDate(DateTime? date) {
      if (date == null) return '__ / __ / ____';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    final fechaApertura = formatDate(historial.fechaApertura ?? historial.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ENCABEZADO INSTITUCIONAL
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.5),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 120,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'D.U.B.S.S.',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                          ),
                          pw.Text(
                            'U.A.G.R.M.',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: PdfColors.red900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 1.5,
                      height: 48,
                      color: PdfColors.black,
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        color: PdfColors.grey200,
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'FORMULARIO',
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                              'INSCRIPCIÓN GIMNASIO UNIVERSITARIO',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 1.5,
                      height: 48,
                      color: PdfColors.black,
                    ),
                    pw.Container(
                      width: 110,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DUBSS-FR-03', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                          pw.Text('Versión: 1.0', style: const pw.TextStyle(fontSize: 7.5)),
                          pw.Text('Apertura: $fechaApertura', style: const pw.TextStyle(fontSize: 7.5)),
                          pw.Text('Aprobado por: DUBSS', style: const pw.TextStyle(fontSize: 7.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // SECCIÓN 1: DATOS DEL SOCIO
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.2),
                ),
                child: pw.Column(
                  children: [
                    _buildRow('NOMBRES Y APELLIDOS:', nombreCompleto),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(child: _buildCell('C.I.:', ci)),
                        pw.Container(width: 1, height: 18, color: PdfColors.black),
                        pw.Expanded(child: _buildCell('CÓD. O REGISTRO:', ru)),
                      ],
                    ),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    _buildRow('FACULTAD/CARRERA/UNIDAD:', historial.facultadCarrera ?? '________________________________________'),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    _buildRow('DOMICILIO:', historial.domicilio ?? '________________________________________'),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    _buildRow('CORREO ELECTRÓNICO:', email),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(child: _buildCell('CELULAR / EMERGENCIA:', celular)),
                        pw.Container(width: 1, height: 18, color: PdfColors.black),
                        pw.Expanded(child: _buildCell('FECHA NACIMIENTO:', formatDate(historial.fechaNacimiento))),
                      ],
                    ),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildCell(
                            'SEXO:',
                            'F ( ${historial.sexo?.toLowerCase() == 'femenino' || historial.sexo == 'F' ? 'X' : ' '} )   M ( ${historial.sexo?.toLowerCase() == 'masculino' || historial.sexo == 'M' ? 'X' : ' '} )',
                          ),
                        ),
                        pw.Container(width: 1, height: 18, color: PdfColors.black),
                        pw.Expanded(child: _buildCell('GRUPO SANGUÍNEO:', historial.grupoSanguineo ?? '________')),
                      ],
                    ),
                    pw.Divider(color: PdfColors.black, height: 1, thickness: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildCell(
                            'ALTURA / PESO:',
                            '${latestDetalle?.altura != null ? "${latestDetalle!.altura} cm" : "____"} / ${latestDetalle?.peso != null ? "${latestDetalle!.peso} kg" : "____"}',
                          ),
                        ),
                        pw.Container(width: 1, height: 18, color: PdfColors.black),
                        pw.Expanded(
                          child: _buildCell(
                            'IMC / PRESIÓN:',
                            '${latestDetalle?.imcCalculado != null && latestDetalle!.imcCalculado > 0 ? latestDetalle.imcCalculado : "____"} | ${latestDetalle?.presion ?? "____"}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // SECCIÓN 2: REGLAS DEL GIMNASIO (Resumen)
              pw.Text(
                'REGLAS DEL GIMNASIO UNIVERSITARIO',
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '• Ingresar en el horario asignado. Uso estricto de zapatillas limpias, ropa deportiva y toalla.\n'
                '• Limpiar equipos después de usarlos. Retornar mancuernas, barras y discos a su lugar.\n'
                '• Prohibido ingresar alimentos (solo botellas de agua). Prohibido ingresar con mochilas a la sala de máquinas.\n'
                '• Seguir las instrucciones del instructor de sala para prevenir lesiones deportivas.',
                style: const pw.TextStyle(fontSize: 7.2, color: PdfColors.grey900, lineSpacing: 1.2),
              ),
              pw.SizedBox(height: 6),

              // SECCIÓN 3: CUESTIONARIO MÉDICO
              pw.Text(
                'CUESTIONARIO MÉDICO - GIMNASIO UNIVERSITARIO',
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
              pw.SizedBox(height: 3),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMedicalQuestion('Cardiovasculares:', ant?.tieneEnfermedadesCardiovasculares == true, ant?.detalleEnfermedadesCardiovasculares),
                    _buildMedicalQuestion('Hipertensión Arterial:', ant?.tieneHipertensionArterial == true, ant?.detalleHipertensionArterial),
                    _buildMedicalQuestion('Pulmonares / Asma:', ant?.tieneEnfermedadesPulmonares == true, ant?.detalleEnfermedadesPulmonares),
                    _buildMedicalQuestion('Diabetes:', ant?.tieneDiabetes == true, ant?.detalleDiabetes),
                    _buildMedicalQuestion('Osteoarticulares / Lesiones:', ant?.tieneEnfermedadesOsteoarticulares == true || ant?.tieneLesiones == true, ant?.detalleEnfermedadesOsteoarticulares ?? ant?.detalleLesiones),
                    _buildMedicalQuestion('Alergias Conocidas:', ant?.tieneAlergias == true, ant?.detalleAlergias),
                    _buildMedicalQuestion('Cirugías / Fracturas previas:', ant?.tieneIntervencionQuirurgica == true || ant?.sufrioFracturasOseas == true, ant?.detalleIntervencionQuirurgica ?? ant?.detalleFracturasOseas),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),

              // DECLARACIÓN JURADA
              pw.Text(
                'DECLARACIÓN JURADA',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Declaro que los datos proporcionados en esta ficha son verdaderos y completos. Me hago responsable civil y penalmente por cualquier situación emergente que pudiera ocurrir, y deslindo de toda responsabilidad al Gimnasio Universitario UAGRM por causas de salud personales. En caso de condición médica positiva me comprometo a presentar certificado médico de aptitud física.',
                style: const pw.TextStyle(fontSize: 6.8, color: PdfColors.grey800, lineSpacing: 1.1),
                textAlign: pw.TextAlign.justify,
              ),
              pw.Spacer(),

              // FIRMAS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Firma del Socio / Estudiante', style: const pw.TextStyle(fontSize: 7.5)),
                      pw.Text('C.I.: $ci', style: const pw.TextStyle(fontSize: 7)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Firma y Sello DUBSS', style: const pw.TextStyle(fontSize: 7.5)),
                      pw.Text('Departamento de Deportes', style: const pw.TextStyle(fontSize: 7)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      width: double.infinity,
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8))),
        ],
      ),
    );
  }

  static pw.Widget _buildCell(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          pw.SizedBox(width: 4),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8))),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicalQuestion(String label, bool isYes, String? detail) {
    final status = isYes ? 'SI ( X ) NO (   )' : 'SI (   ) NO ( X )';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.Text('$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7)),
          pw.Text(status, style: const pw.TextStyle(fontSize: 7)),
          if (isYes && detail != null && detail.isNotEmpty) ...[
            pw.SizedBox(width: 4),
            pw.Expanded(child: pw.Text('Detalle: $detail', style: const pw.TextStyle(fontSize: 7, color: PdfColors.red900))),
          ],
        ],
      ),
    );
  }
}
