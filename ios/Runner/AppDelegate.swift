import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAuFYxq-RX0I1boI5HU5-olArirEi2Ez8k")
    GeneratedPluginRegistrant.register(with: self)
  //  (GMSServices provideAPIKey: @"AIzaSyAuFYxq-RX0I1boI5HU5-olArirEi2Ez8k")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
