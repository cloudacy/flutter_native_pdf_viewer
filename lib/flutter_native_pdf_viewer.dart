import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterNativePDFViewer extends StatelessWidget {
  static const MethodChannel _channel = const MethodChannel('flutter_native_pdf_viewer');

  // This is used in the platform side to register the view.
  final String viewType = 'flutter_native_pdf_viewer';

  // Pass parameters to the platform side.
  final Map<String, dynamic> creationParams;

  FlutterNativePDFViewer({
    @required String path,
  }) : creationParams = <String, dynamic>{
          'path': path,
        };

  static Future<bool> openPDF({
    @required String path,
  }) {
    return _channel.invokeMethod('openPDF', {'path': path});
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Text(
        'Android doesn\'t provide an in-App PDF viewer. Please use the static openPDF method on Android devices.',
      );
    }
  }
}
