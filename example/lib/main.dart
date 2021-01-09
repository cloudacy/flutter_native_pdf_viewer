import 'package:flutter/material.dart';

void main() {
  runApp(FlutterNativePdfViewerApp());
}

class FlutterNativePdfViewerApp extends StatefulWidget {
  @override
  _FlutterNativePdfViewerAppState createState() => _FlutterNativePdfViewerAppState();
}

class _FlutterNativePdfViewerAppState extends State<FlutterNativePdfViewerApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_native_pdf_viewer example'),
        ),
        body: Center(
          child: Text('Test'),
        ),
      ),
    );
  }
}
