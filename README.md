# Embedded Flutter application communication with parent application

These examples show communication between the Flutter Application and the host / native application via _message channels_.  The same Flutter code is used for all three embeddings with a minor switch statement for Web communication.

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

## Android IOS and Web

| Documentation for the flutter embedded repository                                               |
| ----------------------------------------------------------------------------------------------- |
| [Web application with message communication between Flutter and Web](README_WEB.md)             |
| [Android application with message communication between Flutter and Android](README_ANDROID.md) |
| [iOS application with message communication between Flutter and Android](README_IOS.md)         |

## V1

This is the _shortest path_ with as little code as possible.

1. Flutter fills up the entire screen for the iOS and Android applications.  There are no native controls to generate the increment messages
2. This uses a classic single channel specifying the action in a field in the JSON.  Native applications typically do one message per channel and have one channel for each message type
