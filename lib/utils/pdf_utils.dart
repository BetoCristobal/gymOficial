import 'dart:io';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<void> exportarReportePDFYCompartir(ReportesProvider reportesProvider) async {
  final pdf = pw.Document();
  final formatter = DateFormat('dd-MM-yyyy');

  // Crear contenido del PDF
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.all(20),
      build: (context) => [
        pw.Text("Reporte de pagos", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text("Fecha de generación: ${formatter.format(DateTime.now())}", style: pw.TextStyle(fontSize: 14)),
        if(reportesProvider.txtFechaInicioFiltro != null) ...[
          pw.Text("Periodo: ${reportesProvider.txtFechaInicioFiltro} - ${reportesProvider.txtFechaFinFiltro}", style: pw.TextStyle(fontSize: 14)),
          pw.Text("Tipo de pago: ${reportesProvider.txtTipoPago}", style: pw.TextStyle(fontSize: 14)),
        ] else
          pw.Text("Reporte sin filtros aplicados", style: pw.TextStyle(fontSize: 14)),
        pw.Text("Total: \$${reportesProvider.sumaPagos.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(),
          headers: ['#', 'Cliente', "Fecha de pago", "Monto", "Disciplina", "Tipo"],
          cellStyle: pw.TextStyle(fontSize: 11),
          data: List.generate(
            reportesProvider.reportesMostrar.length,
            (index) {
              final r = reportesProvider.reportesMostrar[index];
              return [
                (index + 1).toString(),
                r.nombreCliente,
                formatter.format(r.fechaPago),
                "\$${r.montoPago.toStringAsFixed(2)}",
                r.nombreDisciplina ?? '',
                r.tipoPago,
              ];
            },
          ),
        ),
      ]
    )
  );

  // Guardar el PDF en un archivo temporal
  final tempDir = await getTemporaryDirectory();
  final nombreArchivo = "reporte_pagos_${DateTime.now().microsecondsSinceEpoch}.pdf";
  final archivo = File('${tempDir.path}/$nombreArchivo');
  await archivo.writeAsBytes(await pdf.save());

  // Compartir el PDF usando share_plus
  await Share.shareXFiles([XFile(archivo.path)], text: "Reporte de pagos generado por MyGym");
}