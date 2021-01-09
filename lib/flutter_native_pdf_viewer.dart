import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// class FlutterNativePDFViewer {
//static const MethodChannel _channel = const MethodChannel('flutter_native_pdf_viewer');
//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }

class FlutterNativePDFViewer extends StatelessWidget {
  // This is used in the platform side to register the view.
  final String viewType = 'flutter-native-pdf-viewer-type';

  // Pass parameters to the platform side.
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
