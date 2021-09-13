import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "example.flutter.dev/battery",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch (call.method){
        case "getNativeView":self?.getNativeView(flutterViewController: controller, result: result)
        default:result(FlutterMethodNotImplemented)
        }
      
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func getNativeView(flutterViewController: FlutterViewController, result: FlutterResult) {
        self.window?.rootViewController = nil
        let storyboard : UIStoryboard? = UIStoryboard.init(name: "Main", bundle: nil);
        let viewToPush = storyboard!.instantiateViewController(withIdentifier: "MainTableViewController")//StoryboardID   ThirdViewController()
        
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window.rootViewController = navigationController
        navigationController.isNavigationBarHidden = false
        navigationController.pushViewController(viewToPush, animated: false)
    }
    

  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    if device.batteryState == UIDevice.BatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Battery info unavailable",
                          details: nil))
    } else {
      result(Int(device.batteryLevel * 100))
    }
  }
    
}


