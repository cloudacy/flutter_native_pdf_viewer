import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_pdf_viewer/flutter_native_pdf_viewer.dart';

void main() {
  runApp(FlutterNativePdfViewerApp());
}

class FlutterNativePdfViewerApp extends StatefulWidget {
  @override
  _FlutterNativePdfViewerAppState createState() => _FlutterNativePdfViewerAppState();
}

class _FlutterNativePdfViewerAppState extends State<FlutterNativePdfViewerApp> {
  final _formKey = GlobalKey<FormState>();

  final urlFieldController = TextEditingController();
  Future<String>? pdfFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<String> downloadPDF({
    required String url,
  }) async {
    // If URL is empty or null, replace with https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf.
    if (url == '') {
      url = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    }

    // Download pdf.
    final res = await post(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Invalid response (${res.statusCode}): ${res.body}');
    }

    // Get temporary path directory.
    final tmpDir = await getTemporaryDirectory();

    // Create a temporary file and store the PDF to be readable by the native PDF viewer.
    final pdf = File(tmpDir.path + '/pdf.pdf');
    await pdf.writeAsBytes(res.bodyBytes);

    return pdf.path;
  }

  Future<void> submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      pdfFuture = downloadPDF(url: urlFieldController.text);
    });

    if (Platform.isAndroid) {
      final pdf = await pdfFuture;
      if (pdf != null) {
        FlutterNativePDFViewer.openPDF(path: pdf);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_native_pdf_viewer example'),
        ),
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Enter a PDF URL.'),
                    SizedBox(height: 8),
                    Text(
                      'If no URL is provided, a dummy PDF file will be used (https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf).',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: urlFieldController,
                      decoration: InputDecoration(labelText: 'PDF URL'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: submitForm,
                      child: pdfFuture == null
                          ? Text('Download and view PDF')
                          : FutureBuilder(
                              future: pdfFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  );
                                }

                                return Text('Download and view PDF');
                              },
                            ),
                    ),
                    SizedBox(height: 8),
                    Text('OR'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result == null) {
                          return;
                        }

                        final filePath = result.files.single.path;
                        if (filePath == null) {
                          return;
                        }

                        setState(() {
                          pdfFuture = Future.value(filePath);
                        });

                        if (Platform.isAndroid) {
                          final pdf = await pdfFuture;
                          if (pdf != null) {
                            FlutterNativePDFViewer.openPDF(path: pdf);
                          }
                        }
                      },
                      child: Text('Pick and view PDF'),
                    ),
                  ],
                ),
              ),
            ),
            if (pdfFuture != null && Platform.isIOS)
              Expanded(
                child: FutureBuilder<String>(
                  future: pdfFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text(snapshot.error!.toString());
                    }

                    if (!snapshot.hasData) {
                      return Text('ERROR: No data received.');
                    }

                    final pdf = snapshot.data!;

                    return FlutterNativePDFViewer(
                      path: pdf,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
