import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterNativePDFViewer extends StatelessWidget {
  /// Used to send "open PDF" commands to platforms, which do not provide an in-App native PDF viewer.
  /// This is used for Android devices.
  static const MethodChannel _channel = const MethodChannel('flutter_native_pdf_viewer');

  /// This is used in the platform side to register the view.
  static const viewType = 'flutter_native_pdf_viewer';

  /// Path to the PDF file, which can be accessed by the platform.
  final String path;

  /// Create a new FlutterNativePDFViewer widget, which allows to view a PDF at given `path`,
  /// using the native PDF viewer on iOS devices.
  FlutterNativePDFViewer({
    required this.path,
  });

  /// Sends an "open PDF" command to the platform.
  ///
  /// It should be used on Android devices, since Android doesn't provide an in-App native PDF viewer.
  ///
  /// On iOS, the Widget itself may be used to render the PDF inside the app.
  static Future<bool> openPDF({
    required String path,
  }) async {
    return (await _channel.invokeMethod('openPDF', {'path': path})) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: {'path': path},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Text(
        'Android doesn\'t provide an in-App native PDF viewer. Please use the static openPDF method on Android devices.',
      );
    }
  }
}
