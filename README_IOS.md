# Platform Channels

Goal: Demonstrate Communication between iOS Application and embedded Flutter application

The V1 application can be run as an iOS application.

```mermaid
graph TB;

   subgraph iOS
        subgraph UIWindow
        iosMotionEnded[["motionEnded"]]
        end
        subgraph AppDelegate
            iosMessageHandler
        end
        iosSendMessage[["sendMessage<br/;>FlutterBasicMessageChannel"]]

   end

   subgraph Flutter main
    FloatingActionButton["FloatingActionButton"]
    OnPressHandler
    FlutterPostActionMessage[["postEvent<br/;>BasicMessageChannel"]]
    FlutterMessageListener[["messageListener<br/;>BasicMessageChannel"]]
    Counter

   end

   iosMotionEnded--sendMessge(action:increment)-->iosSendMessage

   iosSendMessage--"{action:increment}"-->FlutterMessageListener

   FloatingActionButton--"onPress"-->OnPressHandler
   Counter-->FlutterPostActionMessage
   OnPressHandler--"increment()"-->Counter
   FlutterPostActionMessage--"{action:incremented}"-->iosMessageHandler
   FlutterMessageListener--"increment()"-->Counter

```

## What the app does

This currently supports bidirectional messaging whenever the counter is incremented in the Flutter module or an event is generated in the iOS program

The iOS application listens for _shake_ events so that we could use the standard Flutter template without having to partition the screen for iOS controls.

### From Flutter to iOS

1. The Flutter code posts a message to the `BasicMessageChannel` on startup
2. The Flutter code posts a message to the `BasicMessageChannel` every time the increment butotn is pressed.
3. The iOS code listens on a `FlutterBasicMessageChannel`
4. The iOS code logs received messages via `print()`.  They show up in the XCode log pane.

### From iOS to Flutter

1. **Shake** the device using `Device -> Shake`
2. The iOS code posts an `{action:increment}` message to the `FlutterBasicMessageChannel`
3. The Flutter code listens for the `{action:incremnt}` message and increments the counter.
4. The flutter code logs the received message.

## Installation Instructions

1. Install XCode
2. Add the appropriate devices configurations to the XCode simulator
3. You may need to install pods

## Runnning the iOS Simulator

1. Verify you have the target simulator loaded. This is done with XCode. You can find instructions at [adding additional simulators](https://developer.apple.com/documentation/safari-developer-tools/adding-additional-simulators)
2. Build the app in VSCode
3. Open the ios directory in `XCode`
4. Run the application
5. Verify the logs at the bottom of `XCode`

## To Do

1. In iOS, converting the received JSON string to a JSON object.
2. Diagrams similar to those for the Android version

## FlutterMethodChannel, FlutterEventChannel, FlutterBasicMessageChannel

The V1 version implements native communication via the `basic message channel` implemented on the iOS side with `FlutterBasicMessageChannel`

| iOS Class                                                                                                       | Flutter class                                                                                  | Description                                           | Flutter to Native | Native to Flutter | Supports Return  |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------------------- | ----------------- | ----------------- |
| [FlutterMethodChanel](https://api.flutter.dev/ios-embedder/interface_flutter_method_channel.html)               | [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)             | Invoke method on the other side                       | Yes               | Yes               | Yes via `result` |
| [FlutterEventChannel](https://api.flutter.dev/ios-embedder/interface_flutter_event_channel.html)                | [EventChannel](https://api.flutter.dev/flutter/services/EventChannel-class.html)               | Creates a stream. Updates can flow in both directions | No                | Yes               | Bidirectional    |
| [FlutterBasicMessageChannel](https://api.flutter.dev/ios-embedder/interface_flutter_basic_message_channel.html) | [BasicMessageChannel](https://api.flutter.dev/flutter/services/BasicMessageChannel-class.html) | Encode and decode using a codec.  No parameters       | Yes               | Yes               | Yes via `reply`  |

### FlutterMethodChannel

Invokes a method on the opposite side.  Uses the codecs show below.

#### FlutterMethodChannel Codecs

| iOS Codec                                                                                                       | Flutter Codec                                                                                  |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [FlutterStandardMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_method_codec.html) | [StandardMEthodCodec](https://api.flutter.dev/flutter/services/StandardMethodCodec-class.html) |
| [FlutterJSONMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_method_codec.html)      | [JSONMethodCodec](https://api.flutter.dev/flutter/services/JSONMethodCodec-class.html)         |

### FlutterEventChannel

ipse lorum

#### EventChannel Codecs

ipse lorum

### FlutterBasicMessage Channel

Supports a single payload with an optional return value.  Uses codecs shown below.

#### Message Channel Codecs

| iOS Codec                                                                                                         | Flutter Codec                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [FlutterStandardMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_message_codec.html) | [StandardMessageCodec](https://api.flutter.dev/flutter/services/StandardMessageCodec-class.html) |
| [FlutterBinaryMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_binary_codec.html)             | [BinaryCodec](https://api.flutter.dev/flutter/services/BinaryCodec-class.html)                   |
| [FlutterJSONMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_message_codec.html)      | [JsonMessageCodec](https://api.flutter.dev/flutter/services/JSONMessageCodec-class.html)         |
| [FlutterStringCodec](https://api.flutter.dev/ios-embedder/interface_flutter_string_codec.html)                    | [StringCodec](https://api.flutter.dev/flutter/services/StringCodec-class.html)                   |

