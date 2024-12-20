import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFBuilder {
  Future<String> _loadPdfFromAssets() async {
    const assetPath = 'assets/files/template.pdf';
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/template.pdf';
    final file = File(tempFilePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return tempFilePath;
  }

  Future<String> _fillPdfFields(
      String templatePath, Map<String, String> fieldValues) async {
    final pdfData = File(templatePath).readAsBytesSync();
    final PdfDocument pdf = PdfDocument(inputBytes: pdfData);

    final form = pdf.form;
    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];

      if (field is PdfTextBoxField && fieldValues.containsKey(field.name)) {
        field.text = fieldValues[field.name]!;  // Fill text fields
        field.font = PdfStandardFont(PdfFontFamily.helvetica, 7);
      } else if (field is PdfCheckBoxField &&
          fieldValues.containsKey(field.name)) {
        field.isChecked = fieldValues[field.name]!.toLowerCase() == 'true';  // Fill checkbox fields
      }
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/filled_template.pdf';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdf.saveSync());

    pdf.dispose();

    return outputPath;
  }

  Future<void> fillAndSavePdf(Map<String, String> fieldValues) async {
    try {
      final templatePath = await _loadPdfFromAssets();

      final filledPdfPath = await _fillPdfFields(templatePath, fieldValues);

      final name = fieldValues['Charaktername_page1'] ?? 'filled_template';

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: "Speichere PDF Charaktersheet",
        fileName: "$name.pdf",
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath != null) {
        final filledPdf = File(filledPdfPath);
        await filledPdf.copy(savePath);
        if (kDebugMode) {
          print("PDF saved at: $savePath");
        }
      } else {
        if (kDebugMode) {
          print("User cancelled the save dialog.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }
}
