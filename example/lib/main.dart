import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_pdf_viewer/flutter_native_pdf_viewer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const FlutterNativePdfViewerApp());
}

class FlutterNativePdfViewerApp extends StatefulWidget {
  const FlutterNativePdfViewerApp({
    super.key,
  });

  @override
  State<FlutterNativePdfViewerApp> createState() => _FlutterNativePdfViewerAppState();
}

class _FlutterNativePdfViewerAppState extends State<FlutterNativePdfViewerApp> {
  final _formKey = GlobalKey<FormState>();

  final urlFieldController = TextEditingController();
  Future<String>? pdfFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<String> _downloadPdf({
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
    final pdf = File('${tmpDir.path}/pdf.pdf');
    await pdf.writeAsBytes(res.bodyBytes);

    return pdf.path;
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      pdfFuture = _downloadPdf(url: urlFieldController.text);
    });

    if (Platform.isAndroid) {
      final pdf = await pdfFuture;
      if (pdf != null) {
        FlutterNativePdfViewer.openPdf(path: pdf);
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
                    const Text('Enter a PDF URL.'),
                    const SizedBox(height: 8),
                    const Text(
                      'If no URL is provided, a dummy PDF file will be used (https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: urlFieldController,
                      decoration: const InputDecoration(labelText: 'PDF URL'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: pdfFuture == null
                          ? const Text('Download and view PDF')
                          : FutureBuilder(
                              future: pdfFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  );
                                }

                                return const Text('Download and view PDF');
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    const Text('OR'),
                    const SizedBox(height: 8),
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
                            FlutterNativePdfViewer.openPdf(path: pdf);
                          }
                        }
                      },
                      child: const Text('Pick and view PDF'),
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
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }

                    if (snapshot.hasError) {
                      return Text(snapshot.error!.toString());
                    }

                    if (!snapshot.hasData) {
                      return const Text('ERROR: No data received.');
                    }

                    final pdf = snapshot.data!;

                    return FlutterNativePdfViewer(path: pdf);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
