import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let channel: String = "com.freemansoft.eventchannel/action"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    print("Creating Chanel")
    let flutterChannel : FlutterBasicMessageChannel? = FlutterBasicMessageChannel(name: channel,
                                            binaryMessenger:controller.binaryMessenger,
                                            codec: FlutterStringCodec.sharedInstance())

    flutterChannel?.setMessageHandler({
        (message: Any?, reply: FlutterReply) in
        print("Received message from Flutter: \(message!)")
        let stringMessage: String = message as! String
        
        let data = stringMessage.data(using: String.Encoding.utf8)!
        print(data)
        // still troubleshooting converting data to json objects
        // reply with an empty json
        reply("{}")
    })
    print("Listener created")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

