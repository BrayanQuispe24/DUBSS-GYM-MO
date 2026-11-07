import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/formulario_solicitud_model.dart';

class PdfFormularioDubssBuilder {
  static Future<Uint8List> buildPdf(
    FormularioSolicitudModel formulario, {
    Map<String, dynamic>? extraData,
  }) async {
    final pdf = pw.Document();

    final fRegistro = formulario.fechaRegistro ?? DateTime.now();
    final fechaApertura =
        '${fRegistro.day.toString().padLeft(2, '0')}/${fRegistro.month.toString().padLeft(2, '0')}/${fRegistro.year}';
    final mesEmision = _obtenerMesEmision(fRegistro);

    final nombreCompleto =
        (formulario.usuarioNombre != null && formulario.usuarioNombre!.trim().isNotEmpty)
            ? formulario.usuarioNombre!.trim()
            : (extraData?['nombre_completo'] ?? 'Brayan Quispe');
    final ci = formulario.usuarioCi ?? extraData?['ci'] ?? '6305913';
    final regUniv = formulario.usuarioRegistro ?? extraData?['registro'] ?? '218042809';
    final facultad = extraData?['facultad_carrera'] ?? 'Ciencias de la Salud';
    final domicilio = extraData?['domicilio'] ?? 'Barrio San Jorge de palmasola';
    final email = formulario.usuarioEmail ??
        extraData?['email'] ??
        'brayansabinoquispearce2021@gmail.com';
    final celular = formulario.usuarioCelular ?? extraData?['celular'] ?? '78494110';
    final fechaNac = extraData?['fecha_nacimiento'] ?? '03/01/2000';
    final sexo = extraData?['sexo'] ?? 'Masculino';
    final isMasc = sexo.toString().toLowerCase().startsWith('m');
    final grupoSang = extraData?['grupo_sanguineo'] ?? 'O+';
    final altura = extraData?['altura']?.toString() ?? '174.00';
    final peso = extraData?['peso']?.toString() ?? '75.40';
    final imc = extraData?['imc']?.toString() ?? '24.90';
    final presion = extraData?['presion']?.toString() ?? '120/8';
    final horarioStr = formulario.horarioTexto ??
        extraData?['horario'] ??
        '07:00 - 09:00 (Mañana)';

    // Antecedentes
    final bool tieneCardio = extraData?['tiene_cardio'] ?? false;
    final String detCardio = extraData?['det_cardio'] ?? (tieneCardio ? 'En control' : '');

    final bool tieneProcCardio = extraData?['tiene_proc_cardio'] ?? false;
    final String detProcCardio = extraData?['det_proc_cardio'] ?? '';

    final bool tieneHiper = extraData?['tiene_hipertension'] ?? false;
    final bool tienePulmonar = extraData?['tiene_pulmonar'] ?? false;
    final bool tieneDiabetes = extraData?['tiene_diabetes'] ?? false;
    final bool tieneOsteo = extraData?['tiene_osteoarticular'] ?? false;
    final bool tieneNeuro = extraData?['tiene_neurologica'] ?? false;
    final bool tieneConv = extraData?['tiene_convulsiones'] ?? false;
    final bool tieneLesiones = extraData?['tiene_lesiones'] ?? false;
    final bool tieneAlergias = extraData?['tiene_alergias'] ?? false;
    final String detCondiciones = extraData?['det_condiciones'] ?? '';

    final bool tieneCirugia = extraData?['tiene_cirugia'] ?? false;
    final String detCirugia = extraData?['det_cirugia'] ?? '';

    final bool tieneFracturas = extraData?['tiene_fracturas'] ?? false;
    final String detFracturas = extraData?['det_fracturas'] ?? '';

    final bool tieneSintomas = extraData?['tiene_sintomas'] ?? false;
    final String detSintomas = extraData?['det_sintomas'] ?? '';

    final String observaciones = extraData?['observaciones'] ?? 'Sin observaciones médicas de riesgo';

    // ─────────────────────────────────────────────────────────────
    // PÁGINA 1
    // ─────────────────────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. ENCABEZADO INSTITUCIONAL
              _buildHeaderTable(fechaApertura),
              pw.SizedBox(height: 6),

              // 2. TABLA DE DATOS DEL SOCIO
              _buildDatosSocioTable(
                nombre: nombreCompleto,
                ci: ci,
                regUniv: regUniv,
                facultad: facultad,
                domicilio: domicilio,
                email: email,
                celular: celular,
                fechaNac: fechaNac,
                isMasc: isMasc,
                grupoSang: grupoSang,
                altura: altura,
                peso: peso,
                imc: imc,
                presion: presion,
                mesEmision: mesEmision,
                horario: horarioStr,
              ),
              pw.SizedBox(height: 6),

              // 3. REGLAS DEL GIMNASIO UNIVERSITARIO
              _buildReglasGimnasio(),
              pw.SizedBox(height: 6),

              // 4. CUESTIONARIO MÉDICO (PARTE 1 Y PARTE 2)
              _buildCuestionarioParte1(
                tieneCardio: tieneCardio,
                detCardio: detCardio,
                tieneProcCardio: tieneProcCardio,
                detProcCardio: detProcCardio,
                tieneHiper: tieneHiper,
                tienePulmonar: tienePulmonar,
                tieneDiabetes: tieneDiabetes,
                tieneOsteo: tieneOsteo,
                tieneNeuro: tieneNeuro,
                tieneConv: tieneConv,
                tieneLesiones: tieneLesiones,
                tieneAlergias: tieneAlergias,
                detCondiciones: detCondiciones,
                tieneCirugia: tieneCirugia,
                detCirugia: detCirugia,
              ),
            ],
          );
        },
      ),
    );

    // ─────────────────────────────────────────────────────────────
    // PÁGINA 2
    // ─────────────────────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Continuación antecedentes deportivos
              _buildDottedQuestion(
                '¿Ha sufrido fracturas óseas?',
                tieneFracturas,
                'Especifique:',
                detFracturas,
              ),
              pw.SizedBox(height: 6),
              _buildDottedQuestion(
                '¿Ha sufrido mareos, deshidratación o pérdida de conocimiento en la práctica deportiva?',
                tieneSintomas,
                'Detalle:',
                detSintomas,
              ),
              pw.SizedBox(height: 14),

              // OBSERVACIONES GENERALES
              _buildSectionTitle('OBSERVACIONES GENERALES DE LA FICHA MÉDICA'),
              pw.SizedBox(height: 4),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, style: pw.BorderStyle.dotted, width: 1),
                  ),
                ),
                child: pw.Text(
                  observaciones,
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
                ),
              ),
              pw.SizedBox(height: 14),

              // VERIFICACIÓN DE DOCUMENTACIÓN
              _buildSectionTitle('VERIFICACIÓN DE DOCUMENTACIÓN Y REQUISITOS ADJUNTOS'),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '[ X ] Cédula de Identidad (Fotocopia)',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '[ X ] Matrícula / Registro Universitario',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '[   ] Certificado de Aptitud Física (en plazo de 15 días)',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '[ X ] Formulario Ficha y Declaración Jurada DUBSS-FR-03',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              // DECLARACIÓN JURADA
              _buildSectionTitle('DECLARACIÓN JURADA'),
              pw.SizedBox(height: 8),
              pw.Text(
                'Declaro que los datos proporcionados en esta ficha son verdaderos y completos. Me hago responsable civil y penalmente por los daños emergentes que pudieran ocurrir por causa mía, ya sea por negligencia, omisión o cualquier otra situación, y deslindo de toda responsabilidad al Gimnasio Universitario UAGRM por causas de salud personales, siendo yo responsable absoluto de mis actos.',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.3),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'He sido informado/a que, si respondí afirmativamente a alguna pregunta relacionada con mi salud, debo presentar en un plazo de 15 días un certificado de aptitud física emitido por un médico matriculado que autorice mi participación en actividades físicas. También declaro conocer y acatar el reglamento interno del gimnasio.',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.3),
              ),
              pw.SizedBox(height: 24),

              // FECHA Y CI
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FECHA: ____ / ____ / ________', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text('C.I.: $ci', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 36),

              // FIRMA
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 240,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text('Firma:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Aclaración firma: $nombreCompleto', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('(Nombre completo)', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────
  // COMPONENTES AUXILIARES DEL PDF
  // ─────────────────────────────────────────────────────────────

  static pw.Widget _buildHeaderTable(String fechaApertura) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Row(
        children: [
          // Left: DUBSS UAGRM
          pw.Container(
            width: 120,
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('D.U.B.S.S.', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('U.A.G.R.M.', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              ],
            ),
          ),
          // Center: Title
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black, width: 1.2),
                  right: pw.BorderSide(color: PdfColors.black, width: 1.2),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('FORMULARIO', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'INSCRIPCIÓN GIMNASIO UNIVERSITARIO',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Right: Meta box
          pw.Container(
            width: 125,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeaderMetaRow('DUBSS-FR-03', isBold: true),
                _buildHeaderMetaRow('Versión: 1.0'),
                _buildHeaderMetaRow('Apertura: $fechaApertura'),
                _buildHeaderMetaRow('Aprobado por: DUBSS', isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderMetaRow(String text, {bool isBold = false, bool isLast = false}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      decoration: pw.BoxDecoration(
        border: isLast ? null : const pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.6)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 7.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  static pw.Widget _buildDatosSocioTable({
    required String nombre,
    required String ci,
    required String regUniv,
    required String facultad,
    required String domicilio,
    required String email,
    required String celular,
    required String fechaNac,
    required bool isMasc,
    required String grupoSang,
    required String altura,
    required String peso,
    required String imc,
    required String presion,
    required String mesEmision,
    required String horario,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          _buildFullRow('NOMBRES Y APELLIDOS:', nombre),
          _buildSplitRow('C.I.:', ci, 'CÓD. O REGISTRO:', regUniv),
          _buildFullRow('FACULTAD/CARRERA/UNIDAD:', facultad),
          _buildFullRow('DOMICILIO:', domicilio),
          _buildFullRow('CORREO ELECTRÓNICO:', email),
          _buildSplitRow('CELULAR / EMERGENCIA:', celular, 'FECHA DE NACIMIENTO:', fechaNac),
          _buildSplitRow(
            'SEXO:',
            'F ( ${!isMasc ? 'X' : ' '} )  M ( ${isMasc ? 'X' : ' '} )',
            'GRUPO SANGUÍNEO:',
            grupoSang,
          ),
          _buildSplitRow(
            'ALTURA:',
            '$altura cm | PESO: $peso kg',
            'IMC:',
            '$imc | PRESIÓN: $presion',
          ),
          _buildSplitRow(
            'MES DE EMISIÓN:',
            mesEmision,
            'HORARIO:',
            horario,
            isLast: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFullRow(String label, String value, {bool isLast = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: pw.BoxDecoration(
        border: isLast ? null : const pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.6)),
      ),
      child: pw.Row(
        children: [
          pw.Text('$label ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 7.5)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSplitRow(
    String label1,
    String val1,
    String label2,
    String val2, {
    bool isLast = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: isLast ? null : const pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.6)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.6)),
              ),
              child: pw.Row(
                children: [
                  pw.Text('$label1 ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(val1, style: const pw.TextStyle(fontSize: 7.5)),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              child: pw.Row(
                children: [
                  pw.Text('$label2 ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(val2, style: const pw.TextStyle(fontSize: 7.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReglasGimnasio() {
    final reglas = [
      'Ingresar al gimnasio en el horario que se inscribió, Prohibido asistir en otro horario',
      'Limpiar los equipos después de utilizarlos',
      'Prohibido el ingreso de alimentos en el área de ejercicio, solamente podrá ingresar con botellas con agua.',
      'Prohibido el ingreso de niños al área de musculación',
      'Es obligatorio el uso de zapatillas, ropa deportiva y una toallita',
      'Uso de discos y mancuernas solo en el área de piso de goma',
      'Los diferentes implementos y equipos del gimnasio deben ser compartidos por todos los usuarios',
      'Cuide su pertenencia, en caso de pérdida el gimnasio no se hace responsable',
      'Prohibido el ingreso en estado de embriaguez y/o bajo efectos de sustancias psicoactivas',
      'Prohibido realizar rutinas sin la supervisión del instructor, la Universidad no se hace responsable por los accidentes derivados de la mala utilización de las máquinas o implementos deportivos.',
      'Todo usuario está en el deber de retornar los implementos (mancuernas, discos y barras) que utilice al lugar que corresponda y velar por el buen uso de estos en el gimnasio.',
      'Si maltratar los implementos y equipos, el gimnasio se reserva el derecho de llamar la atención al usuario que contravenga esta recomendación o hacer la reposición de los daños ocasionados',
      'Prohibido el ingreso a la sala de ejercicios con bolsones y mochilas, estos deben dejar en los casilleros que brinda el gimnasio.',
      'El incumplimiento del reglamento puede ocasionar retiro indefinido del uso del gimnasio, además de acarrear sanciones disciplinarias.',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('REGLAS DEL GIMNASIO UNIVERSITARIO'),
        pw.SizedBox(height: 3),
        ...reglas.map(
          (r) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 1.5, left: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(top: 2.5, right: 4),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(r, style: const pw.TextStyle(fontSize: 6.7, lineSpacing: 1.15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCuestionarioParte1({
    required bool tieneCardio,
    required String detCardio,
    required bool tieneProcCardio,
    required String detProcCardio,
    required bool tieneHiper,
    required bool tienePulmonar,
    required bool tieneDiabetes,
    required bool tieneOsteo,
    required bool tieneNeuro,
    required bool tieneConv,
    required bool tieneLesiones,
    required bool tieneAlergias,
    required String detCondiciones,
    required bool tieneCirugia,
    required String detCirugia,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('CUESTIONARIO MÉDICO - GIMNASIO UNIVERSITARIO'),
        pw.SizedBox(height: 2),
        pw.Text(
          'Por favor, responda con sinceridad las siguientes preguntas sobre su salud:',
          style: pw.TextStyle(fontSize: 7.2, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 3),

        // 1. Antecedentes
        pw.Text('1. Antecedentes médicos generales', style: pw.TextStyle(fontSize: 7.6, fontWeight: pw.FontWeight.bold)),
        _buildDottedQuestion(
          '¿Tiene usted antecedentes de enfermedades cardiovasculares?',
          tieneCardio,
          'en caso sea afirmativo, especifique:',
          detCardio,
        ),
        _buildDottedQuestion(
          '¿Se le ha realizado algún procedimiento cardiovascular (angioplastia, cirugía de bypass, recambio valvular, marcapasos, cardiodesfibrilador)?',
          tieneProcCardio,
          'En caso afirmativo especifique:',
          detProcCardio,
        ),
        pw.SizedBox(height: 4),

        // 2. Condiciones
        pw.Text('2. ¿Padece alguna de las siguientes condiciones? (Marque con X)', style: pw.TextStyle(fontSize: 7.6, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildCheckText('Hipertensión arterial', tieneHiper)),
            pw.Expanded(child: _buildCheckText('Enfermedades pulmonares', tienePulmonar)),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(child: _buildCheckText('Diabetes', tieneDiabetes)),
            pw.Expanded(child: _buildCheckText('Osteoarticulares', tieneOsteo)),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(child: _buildCheckText('Neurológicas', tieneNeuro)),
            pw.Expanded(child: _buildCheckText('Convulsiones', tieneConv)),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(child: _buildCheckText('Lesiones articulares/musculares', tieneLesiones)),
            pw.Expanded(child: _buildCheckText('Alergias conocidas', tieneAlergias)),
          ],
        ),
        pw.SizedBox(height: 2),
        _buildDottedDetail('En caso de respuesta afirmativa a alguna de las preguntas anteriores, detalle:', detCondiciones),
        pw.SizedBox(height: 4),

        // 3. Intervenciones
        pw.Text('3. Intervenciones y antecedentes deportivos', style: pw.TextStyle(fontSize: 7.6, fontWeight: pw.FontWeight.bold)),
        _buildDottedQuestion(
          '¿Le realizaron alguna intervención quirúrgica?',
          tieneCirugia,
          'Especifique:',
          detCirugia,
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Center(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  static pw.Widget _buildCheckText(String label, bool isChecked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Text(
        '$label: SI ( ${isChecked ? 'X' : ' '} ) NO ( ${!isChecked ? 'X' : ' '} )',
        style: const pw.TextStyle(fontSize: 7),
      ),
    );
  }

  static pw.Widget _buildDottedQuestion(String question, bool isSi, String subPrompt, String detail) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$question SI ( ${isSi ? 'X' : ' '} ) NO ( ${!isSi ? 'X' : ' '} ) $subPrompt',
            style: const pw.TextStyle(fontSize: 7.2),
          ),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, style: pw.BorderStyle.dotted, width: 0.6)),
            ),
            child: pw.Text(detail, style: const pw.TextStyle(fontSize: 7.2)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDottedDetail(String prompt, String detail) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(prompt, style: const pw.TextStyle(fontSize: 7.2)),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, style: pw.BorderStyle.dotted, width: 0.6)),
            ),
            child: pw.Text(detail, style: const pw.TextStyle(fontSize: 7.2)),
          ),
        ],
      ),
    );
  }

  static String _obtenerMesEmision(DateTime fecha) {
    const meses = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE',
    ];
    final m = meses[fecha.month - 1];
    return '$m DE ${fecha.year}';
  }
}
