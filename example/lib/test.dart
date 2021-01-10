import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_pdf_viewer/flutter_native_pdf_viewer.dart';

class ExampleWidget extends StatefulWidget {
  final File pdf;

  ExampleWidget({
    this.pdf,
  });

  @override
  _ExampleWidgetState createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    super.initState();

    // Share a PDF to be opened by an external PDF viewer app on android devices.
    if (Platform.isAndroid) {
      FlutterNativePDFViewer.openPDF(path: widget.pdf.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // iOS provides an in-App option, using PDFKit.
    if (Platform.isIOS) {
      return FlutterNativePDFViewer(path: widget.pdf.path);
    } else {
      return Text('Not supported.');
    }
  }
}
