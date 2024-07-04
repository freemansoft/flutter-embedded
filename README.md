# Embedded Flutter application communication with parent application

These examples show communication between the Flutter Application and the host / native application via _message channels_.  The same Flutter code is used for all three embeddings with a minor switch statement for Web communication.

## Commmon flow

This is the platform and implemenation agnostic view that shows that the increment function can happen

```mermaid
graph TD;
    subgraph host
        HostControl[Control]
        HostChannel[MessageChannel]
        HostChannel2[MessageChannel]
        HostListener[Listener]
    end

    subgraph flutter
        FlutterControl[Control]
        FlutterChannel[MessageChannel]
        FlutterChannel2[MessageChannel]
        FlutterListener[Listener]
        Counter
    end

    FlutterControl--increment()-->Counter--{action:incremented}-->FlutterChannel2-.{action:incremented}.->HostChannel2-->HostListener

    HostControl--increment()-->HostChannel-."{action:incremnt}".->FlutterChannel

    FlutterChannel--"{action:increment}"-->FlutterListener--increment()-->Counter

```

## Platform specific implementations

Additional details are available for each platform implementation

| Platform                                                                                        |
| ----------------------------------------------------------------------------------------------- |
| [Web application with message communication between Flutter and Web](README_WEB.md)             |
| [Android application with message communication between Flutter and Android](README_ANDROID.md) |
| [iOS application with message communication between Flutter and Android](README_IOS.md)         |

## Mobile Native communication

Communication between the Mobile native code and Flutter happens over platform channels.  Web commnication happens via window messaging

### Flutter Channel types

There are three native platform channel types.  V1 of this application uses the `Message Channel`

| Channel type and Flutter class                                                                 | Description                                           | Flutter to Native | Native to Flutter | Supports Return  |
| ---------------------------------------------------------------------------------------------- | ----------------------------------------------------- | ----------------- | ----------------- | ---------------- |
| [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)             | Invoke method on the other side                       | Yes               | Yes               | Yes via `result` |
| [EventChannel](https://api.flutter.dev/flutter/services/EventChannel-class.html)               | Creates a stream. Updates can flow in both directions | No                | Yes               | Bidirectional    |
| [BasicMessageChannel](https://api.flutter.dev/flutter/services/BasicMessageChannel-class.html) | Encode and decode using a codec.  No parameters       | Yes               | Yes               | Yes via `reply`  |

### FlutterMethodChannel, FlutterEventChannel, FlutterBasicMessageChannel

Version V1 implements native communication via the `basic message channel` implemented on the iOS side with `FlutterBasicMessageChannel`

| Flutter Class                                                                                  | iOS Class                                                                                                       | Android Class                                                                                            |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)             | [FlutterMethodChanel](https://api.flutter.dev/ios-embedder/interface_flutter_method_channel.html)               | [MethodChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.html)             |
| [EventChannel](https://api.flutter.dev/flutter/services/EventChannel-class.html)               | [FlutterEventChannel](https://api.flutter.dev/ios-embedder/interface_flutter_event_channel.html)                | [EventChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.html)               |
| [BasicMessageChannel](https://api.flutter.dev/flutter/services/BasicMessageChannel-class.html) | [FlutterBasicMessageChannel](https://api.flutter.dev/ios-embedder/interface_flutter_basic_message_channel.html) | [BasicMessageChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/BasicMessageChannel.html) |

#### MethodChannel Codes

Invokes a method on the opposite side.  Uses the codecs show below.

| Flutter Codec Class                                                                            | iOSCodec Class                                                                                                  | Android Codec Class                                                                                      |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [StandardMEthodCodec](https://api.flutter.dev/flutter/services/StandardMethodCodec-class.html) | [FlutterStandardMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_method_codec.html) | [StandardMethodCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StandardMethodCodec.html) |
| [JSONMethodCodec](https://api.flutter.dev/flutter/services/JSONMethodCodec-class.html)         | [FlutterJSONMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_method_codec.html)      | [JSONMethodCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/JSONMethodCodec.html)         |

### Message Channel Codecs

Supports a single payload with an optional return value.  Uses codecs shown below.

| Flutter Codec Class                                                                              | iOS Codec Class                                                                                                   | Android Codec Class                                                                                        |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [StandardMessageCodec](https://api.flutter.dev/flutter/services/StandardMessageCodec-class.html) | [FlutterStandardMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_message_codec.html) | [StandardMessageCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StandardMessageCodec.html) |
| [BinaryCodec](https://api.flutter.dev/flutter/services/BinaryCodec-class.html)                   | [FlutterBinaryMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_binary_codec.html)             | [BinaryCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/BinaryCodec.html)                   |
| [JsonMessageCodec](https://api.flutter.dev/flutter/services/JSONMessageCodec-class.html)         | [FlutterJSONMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_message_codec.html)      | [JSONMessageCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/JSONMessageCodec.html)         |
| [StringCodec](https://api.flutter.dev/flutter/services/StringCodec-class.html)                   | [FlutterStringCodec](https://api.flutter.dev/ios-embedder/interface_flutter_string_codec.html)                    | [StringCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StringCodec.html)                   |

## V1

This is the _shortest path_ with as little code as possible.

1. Flutter fills up the entire screen for the iOS and Android applications.  There are no native controls to generate the increment messages
2. This uses a classic single channel specifying the action in a field in the JSON.  Native applications typically do one message per channel and have one channel for each message type
