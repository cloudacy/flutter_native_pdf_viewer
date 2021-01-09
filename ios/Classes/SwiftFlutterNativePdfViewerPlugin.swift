import Flutter
import UIKit

public class SwiftFlutterNativePdfViewerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_native_pdf_viewer", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterNativePdfViewerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
