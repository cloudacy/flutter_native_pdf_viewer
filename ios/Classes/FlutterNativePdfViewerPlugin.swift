import Flutter
import UIKit

public class FlutterNativePdfViewerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_native_pdf_viewer", binaryMessenger: registrar.messenger())
    let instance = FlutterNativePdfViewerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let pdfViewerFactory = FlutterNativePdfViewerFactory(messenger: registrar.messenger())
    registrar.register(pdfViewerFactory, withId: "flutter_native_pdf_viewer")
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
