import Flutter
import UIKit

let channel: String = "com.freemansoft.eventchannel/action"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {


    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        print("Creating Channel")
        let flutterChannel : FlutterBasicMessageChannel? = FlutterBasicMessageChannel(name: channel,
                                                                                      binaryMessenger:controller.binaryMessenger,
                                                                                      codec: FlutterJSONMessageCodec.sharedInstance())
        
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

// https://stackoverflow.com/questions/34773030/detecting-shake-in-appdelegate
extension UIWindow {
    
    func setRootViewController(_ viewController: UIViewController) {
            self.rootViewController = viewController
    }

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        if motion == .motionShake {
            print("Device shaken")
            let controller : FlutterViewController = self.rootViewController as! FlutterViewController
            
            print("Creating Channel")
            let flutterChannel : FlutterBasicMessageChannel? = FlutterBasicMessageChannel(name: channel,
                                                                                          binaryMessenger:controller.binaryMessenger,
                                                                                          codec: FlutterJSONMessageCodec.sharedInstance())
            flutterChannel?.sendMessage("{\"action\":\"increment\"}")
        }
    }
}
