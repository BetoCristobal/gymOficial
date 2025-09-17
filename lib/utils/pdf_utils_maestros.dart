import 'dart:io';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String> exportarReportePDFParaCompartir(ReportesProvider reportesProvider) async {
  final pdf = pw.Document();
  final formatter = DateFormat('dd-MM-yyyy');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      build: (context) => [
        pw.Text("Reporte de pagos", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if(reportesProvider.txtFechaInicioFiltro != null) ...[
          pw.Text("Periodo: ${reportesProvider.txtFechaInicioFiltro} - ${reportesProvider.txtFechaFinFiltro}", style: pw.TextStyle(fontSize: 18)),
          pw.Text("Tipo de pago: ${reportesProvider.txtTipoPago}", style: pw.TextStyle(fontSize: 18)),
        ] else
          pw.Text("Reporte sin filtros aplicados", style: pw.TextStyle(fontSize: 18)),
        pw.Text("Total: \$${reportesProvider.sumaPagos.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(),
          headers: ['Cliente', "Fecha de pago", "Monto", "Tipo"],
          data: reportesProvider.reportesMostrar.map((r) {
              return[
                r.nombreCliente,
                formatter.format(r.fechaPago),
                "\$${r.montoPago.toStringAsFixed(2)}",
                r.tipoPago,
              ];
            }
          ).toList()
        ),
      ]
    )
  );

  Directory? documentosDir;
  if (Platform.isAndroid) {
    final String documentosPath = "/storage/emulated/0/Documents";
    documentosDir = Directory(documentosPath);
    if (!await documentosDir.exists()) {
      await documentosDir.create(recursive: true);
    }
  } else {
    documentosDir = await getApplicationDocumentsDirectory();
  }

  final nombreArchivo = "reporte_pagos_${DateTime.now().microsecondsSinceEpoch}.pdf";
  final archivo = File('${documentosDir.path}/$nombreArchivo');
  await archivo.writeAsBytes(await pdf.save());

  print("✅ PDF guardado en Documentos");
  print("Ruta del archivo: ${archivo.path}");

  return archivo.path; // <--- Devuelve la ruta del PDF
}