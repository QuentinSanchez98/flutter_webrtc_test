import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private var eventChannel: FlutterEventChannel?
  private let streamHandler = StreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window.rootViewController as! FlutterViewController
    eventChannel = FlutterEventChannel(name: "com.quentinsanchez.test/events", binaryMessenger: controller.binaryMessenger)

    if #available(iOS 10.0, *) {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
        let number = self.getFileDescriptors()
        print(number)
        self.streamHandler.addNumber("\(number)")
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    eventChannel?.setStreamHandler(streamHandler)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func getFileDescriptors() -> Int {
    (0...getdtablesize()).reduce(0) { (result, fd) in result + (fcntl(fd, F_GETFL) >= 0 ? 1 : 0) }
  }
}

class StreamHandler: NSObject, FlutterStreamHandler {

  var eventSink: FlutterEventSink?
  var queue: [String] = []

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    queue.forEach({ events($0) })
    queue.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  func addNumber(_ number: String) -> Bool {
    guard let eventSink = eventSink else {
      queue.append(number)
      return false
    }
    eventSink(number)
    return true
  }
}

