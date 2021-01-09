import Flutter
import UIKit
import PDFKit

class FLNativePDFViewerFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger
  
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }
  
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return FLNativePDFViewer(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger
    )
  }
  
  // Required to receive arguments.
  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class FLNativePDFViewer: NSObject, FlutterPlatformView {
  private var _view: UIView
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    _view = UIView()
    super.init()
    
    if let view = createView(view: _view, frame: frame, args: args) {
      _view = view
    }
  }
  
  func view() -> UIView {
    return _view
  }
  
  func createView(view _view: UIView, frame: CGRect, args _args: Any?) -> UIView? {
    if #available(iOS 11.0, *) {
      guard let args = _args as? Dictionary<String, Any> else {
        let label = UILabel()
        label.text = "ERROR: Invalid or missing arguments provided to flutter_native_pdf_viewer widget: \(String(describing: _args))."
        _view.addSubview(label)
        return nil
      }
      
      guard let pdfPath = args["path"] as? String else {
        let label = UILabel()
        label.text = "ERROR: Invalid or missing \"path\" argument provided to flutter_native_pdf_viewer widget: \(String(describing: _args))."
        _view.addSubview(label)
        return nil
      }
      
      let pdfView = PDFView()
      pdfView.document = PDFDocument(url: URL(fileURLWithPath: pdfPath))
      pdfView.autoScales = true
      return pdfView
    } else {
      let label = UILabel()
      label.text = "flutter_native_pdf_viewer is not supported for iOS < 11.0"
      _view.addSubview(label)
      return nil
    }
  }
}
