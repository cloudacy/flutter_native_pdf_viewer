import Flutter
import UIKit
import PDFKit

class FlutterNativePdfViewerFactory: NSObject, FlutterPlatformViewFactory {
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
    return FlutterNativePdfViewer(
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

class FlutterNativePdfViewer: NSObject, FlutterPlatformView, PDFDocumentDelegate {
  private var _view: UIView
  
  private var pdfDocument: PDFDocument?
  private var pdfSelections: [PDFSelection] = [PDFSelection]()
  
  private var channel: FlutterMethodChannel?
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    _view = UIView()
    super.init()
    
    if let m = messenger {
      channel = FlutterMethodChannel(name: "flutter_native_pdf_viewer_search_\(viewId)", binaryMessenger: m)
      channel?.setMethodCallHandler(methodCallHandler)
    }
    
    createView(view: _view, frame: frame, args: args)
  }
  
  func view() -> UIView {
    return _view
  }
  
  func createView(view _view: UIView, frame: CGRect, args _args: Any?) {
    guard let args = _args as? Dictionary<String, Any> else {
      let label = UILabel()
      label.text = "ERROR: Invalid or missing arguments provided to flutter_native_pdf_viewer widget: \(String(describing: _args))."
      self._view = label
      return
    }
    
    guard let pdfPath = args["path"] as? String else {
      let label = UILabel()
      label.text = "ERROR: Invalid or missing \"path\" argument provided to flutter_native_pdf_viewer widget: \(String(describing: _args))."
      self._view = label
      return
    }
    
    let pdf = PDFDocument(url: URL(fileURLWithPath: pdfPath))
    pdf?.delegate = self
    self.pdfDocument = pdf
    
    let pdfView = PDFView()
    pdfView.document = self.pdfDocument
    pdfView.autoScales = true
    
    self._view = pdfView
  }
  
  func methodCallHandler(_ call: FlutterMethodCall, _ result: FlutterResult) -> Void {
    if call.method == "search" {
      self.startPDFSearch(call, result)
    } else if call.method == "requestSearchResultIndex" {
      self.goToPDFSelectionFromFlutter(call, result)
    }
  }
  
  func startPDFSearch(_ call: FlutterMethodCall, _ result: FlutterResult) {
    guard let query = call.arguments as? String else {
      result(FlutterError(code: "INVALID_SEARCH_QUERY_TYPE", message: "The given search query argument must be of type String.", details: call.arguments))
      return
    }
    
    self.pdfDocument?.cancelFindString()
    self.pdfSelections.removeAll()
    self.pdfDocument?.beginFindString(query, withOptions: .caseInsensitive)
    
    result("searching for \(query) ...")
  }
  
  func goToPDFSelectionFromFlutter(_ call: FlutterMethodCall, _ result: FlutterResult) {
    guard let index = call.arguments as? Int else {
      result(FlutterError(code: "INVALID_SEARCH_RESULT_INDEX_TYPE", message: "The given search result index argument must be of type Int.", details: call.arguments))
      return
    }
    
    let clampedIndex = min(max(index, 1), self.pdfSelections.count)
    
    // Abort if clamped index is invalid.
    // This can be the case if available PDF selections are empty.
    if clampedIndex < 1 {
      return
    }
    
    self.usePDFSelection(self.pdfSelections[clampedIndex - 1])
    
    // Report new search result index to Flutter.
    if let channel = self.channel {
      channel.invokeMethod("searchResultIndex", arguments: clampedIndex)
    }
    
    result("switching to search result at index \(clampedIndex) ...")
  }
  
  func usePDFSelection(_ selection: PDFSelection) {
    if let pdf = self.pdfDocument {
      pdf.outlineItem(for: selection)
    }
    if let pdfView = self._view as? PDFView {
      selection.color = UIColor.yellow
      pdfView.setCurrentSelection(selection, animate: true)
      pdfView.go(to: selection)
    }
  }
  
  // This method gets called for each search result.
  // We collect the results and resport it to Flutter after the documentDidEndDocumentFind notification.
  func didMatchString(_ instance: PDFSelection) {
    pdfSelections.append(instance)
  }
  
  func documentDidEndDocumentFind(_ notification: Notification) {
    // Select first search result if possible.
    if let selection = self.pdfSelections.first {
      usePDFSelection(selection)
      
      // Report new search result index to Flutter.
      if let channel = self.channel {
        channel.invokeMethod("searchResultIndex", arguments: 1)
      }
    }
    
    // Report new search result size to Flutter.
    if let channel = self.channel {
      channel.invokeMethod("searchResultSize", arguments: pdfSelections.count)
    }
  }
}
