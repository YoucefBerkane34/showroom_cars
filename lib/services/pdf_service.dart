import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> printInvoice({
    required String clientName,
    required String vehicle,
    required double price,
    required double paid,
    required double remaining,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("SHOWROOM INVOICE", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text("Client: $clientName"),
              pw.Text("Vehicle: $vehicle"),
              pw.SizedBox(height: 20),
              pw.Text("Price: $price DA"),
              pw.Text("Paid: $paid DA"),
              pw.Text("Remaining: $remaining DA"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
