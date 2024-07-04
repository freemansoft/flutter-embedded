# Android Integration in this repository

Goal: Demonstrate Communication between Android Application and embedded Flutter application

The V1 application can be run as an Android application.

```mermaid
graph TB;

   subgraph Android MainActivity
      OnTouchEvent["onTouchEvent"]
      AndroidPostMessage[["postEvent<br/;>BasicMessageChannel"]]
      AndroidMessageHandler[["messageHandler<br/;>BasicMessageChannel"]]

   end

   subgraph Flutter main
      FloatingActionButton["FloatingActionButton"]
      OnPressHandler
      FlutterPostActionMessage[["postEvent<br/;>BasicMessageChannel"]]
      FlutterMessageListener[["messageListener<br/;>BasicMessageChannel"]]
      Counter

   end

   OnTouchEvent--post(action:increment)-->AndroidPostMessage

   AndroidPostMessage--"{action:increment}"-->FlutterMessageListener

   FloatingActionButton--"onPress"-->OnPressHandler
   Counter-->FlutterPostActionMessage
   OnPressHandler--"increment()"-->Counter
   FlutterPostActionMessage--"{action:incremented}"-->AndroidMessageHandler
   FlutterMessageListener--"increment()"-->Counter

```

## What the app does

This currently supports bidirectional messaging whenever the counter is incremented in the Flutter module or an event is generated in the Android program.

1. Runs a single counter Flutter application embedded in an android app
2. The Flutter application sends the `initialized` message on startup via the `BasicMessageChannel`.
   1. You can see this in the logs and in the `Toast` popup.
3. The Flutter counter application includes an `+` / `Increment` button
   1. The `increment` button increments the counter when the plus button is pressed.
4. The Android application has a `gesture` handler that can pick up any mouse down outside the flutter application.  The application doesn't run with fragments so the only gesture aware area is the area at the bottom of the emulator where the slide up bar is.
   1. The `Android` gesture handler posts an `increment` message to the the `BasicMessageChannel`
   2. The `Flutter` application listens for `increment` messages on the `BasicMessageChannel` which invokes the Flutter `increment` function.
5. Flutter sends an `incremented` message every time it increments
   1. You can see this in the logs and in the `Toast` popup.  Look for `received message:`

We use the touch area outside the drawing area so that we didn't have to fragment the screen to display any Android controls.

![Touch sensitive area in android app](images/2024-05-04_18-50-27.png)

## Running the Android app

1. Start the android emulator from VS Code. You can do this by
   1. Clicking on the device in the VSCode status bar.
   2. `Control-shift-P` then `Flutter`  then `Launch Emulator`
2. (optional) Run the Android studio and open `logcat` to see the android logs
   1. It looks like the andoid debug logs are also visible in the Visual Studio Code debug console
3. Start the application in VSCode by highlighting the `main.dart` and then pressing right mouse to expose the `start debubgging` menu item.
   1. You can also use the `VSCode` run menu.  Select `Flutter` and press the run icon.
4. This should launch the application in the android emulator

## To Do

* Convert the application use Fragments and put the Flutter engine in a fragment. Add an android button that can send a message into flutter like demonstrated in the web app.
  * Currently uses no Fragments and dectects press actions outside the Flutter application
  * Fragments not implemented because the Flutter android template doesn't create them so I left this code like people would see it in a new Flutter project.
* _?_ Run two copies of the flutter code in a Fragment with a swipe operation or a scroll area or something. (links from before I understood we should use Fragments)
  * See <https://medium.com/flutter/flutter-platform-channels-ce7f540a104e>
  * See  <https://github.com/flutter/samples/tree/main/add_to_app/multiple_flutters>
  * See <https://github.com/flutter/samples/blob/main/add_to_app/multiple_flutters/multiple_flutters_android/app/src/main/java/dev/flutter/multipleflutters/DoubleFlutterActivity.kt>
