# Embedded Flutter application communication with parent application

These examples show communication between the Flutter Application and the host / native application via _message channels_.  The same Flutter code is used for all three embeddings with a minor switch statement for Web communication.

## Message flow

This application uses message channels for mobile platform/Flutter communication. Both Flutter and Native can initiate an increment operation.  The native side always receives a message from Flutter _after_ an increment operation has occured.

```mermaid
graph TB;
    subgraph host
        HostControl[Control and UI Listener]
        HostChannel[Message Channel]

        HostChannel2[Message Channel]
        HostListener[Message Listener]
    end

    subgraph flutter
        FlutterControl[Control and UI Listener]
        FlutterChannel[Message Channel]

        FlutterChannel2[Message Channel]
        FlutterListener[Message Listener]
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

| Channel type and Flutter class                                                         | Description                                           | Flutter <br/> Native | Native <br/> Flutter | Supports <br/>Return |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------- | -------------------- | -------------------- | -------------------- |
| [Method Invocation](https://api.flutter.dev/flutter/services/MethodChannel-class.html) | Invoke method on the other side                       | Yes                  | Yes                  | Via `result`         |
| [Message](https://api.flutter.dev/flutter/services/BasicMessageChannel-class.html)     | Sends a message to remote listener                    | Yes                  | Yes                  | Via `reply`          |
| [Event](https://api.flutter.dev/flutter/services/EventChannel-class.html)              | Streams and sinks. Events can flow in both directions | Yes                  | Yes                  | Bidirectional        |

### FlutterMethodChannel, FlutterEventChannel, FlutterBasicMessageChannel

Version V1 demonstration code implements native communication via a `message channel`.

| Flutter Class                                                                                  | iOS Class                                                                                                       | Android Class                                                                                            |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)             | [FlutterMethodChanel](https://api.flutter.dev/ios-embedder/interface_flutter_method_channel.html)               | [MethodChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.html)             |
| [EventChannel](https://api.flutter.dev/flutter/services/EventChannel-class.html)               | [FlutterEventChannel](https://api.flutter.dev/ios-embedder/interface_flutter_event_channel.html)                | [EventChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.html)               |
| [BasicMessageChannel](https://api.flutter.dev/flutter/services/BasicMessageChannel-class.html) | [FlutterBasicMessageChannel](https://api.flutter.dev/ios-embedder/interface_flutter_basic_message_channel.html) | [BasicMessageChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/BasicMessageChannel.html) |

### Method Channel Codecs MethodCodec

Invokes a method on the opposite side.  Uses the codecs shown below.

| Flutter Codec Class                                                                            | iOS Codec Class                                                                                                 | Android Codec Class                                                                                      |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [MethodCodec Interface](https://api.flutter.dev/flutter/services/MethodCodec-class.html)       | ...                                                                                                             | ...                                                                                                      |
| [StandardMethodCodec](https://api.flutter.dev/flutter/services/StandardMethodCodec-class.html) | [FlutterStandardMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_method_codec.html) | [StandardMethodCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StandardMethodCodec.html) |
| [JSONMethodCodec](https://api.flutter.dev/flutter/services/JSONMethodCodec-class.html)         | [FlutterJSONMethodCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_method_codec.html)      | [JSONMethodCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/JSONMethodCodec.html)         |

### Message Channel Codecs

Supports a single payload with an optional return value. Uses codecs shown below.

| Flutter Codec Class                                                                              | iOS Codec Class                                                                                                   | Android Codec Class                                                                                        |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [MessageCodec Interface](https://api.flutter.dev/flutter/services/MessageCodec-class.html)       | ...                                                                                                               | ...                                                                                                        |
| [StandardMessageCodec](https://api.flutter.dev/flutter/services/StandardMessageCodec-class.html) | [FlutterStandardMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_standard_message_codec.html) | [StandardMessageCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StandardMessageCodec.html) |
| [BinaryCodec](https://api.flutter.dev/flutter/services/BinaryCodec-class.html)                   | [FlutterBinaryMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_binary_codec.html)             | [BinaryCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/BinaryCodec.html)                   |
| [JsonMessageCodec](https://api.flutter.dev/flutter/services/JSONMessageCodec-class.html)         | [FlutterJSONMessageCodec](https://api.flutter.dev/ios-embedder/interface_flutter_j_s_o_n_message_codec.html)      | [JSONMessageCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/JSONMessageCodec.html)         |
| [StringCodec](https://api.flutter.dev/flutter/services/StringCodec-class.html)                   | [FlutterStringCodec](https://api.flutter.dev/ios-embedder/interface_flutter_string_codec.html)                    | [StringCodec](https://api.flutter.dev/javadoc/io/flutter/plugin/common/StringCodec.html)                   |

### Event Channel

Event channels are continuous broadcast streams that use a `MethodCodec`.

| Flutter Codec Class | iOS Codec Class | Android Codec Class |
| ------------------- | --------------- | ------------------- |
| See MethodCodec     | See MethodCodec | See MethodCodec     |

## V1

This is the _shortest path_ with as little code as possible.

1. Flutter fills up the entire screen for the iOS and Android applications.  There are no native controls to generate the increment messages
2. This uses a classic single channel specifying the action in a field in the JSON.  Native applications typically do one message per channel and have one channel for each message type
