# Demonstrate Communication between Android Application and embedded Flutter application

The V1 application can be run as an android engine.

## What the app does

1. Runs a single counter embedded in an android app
2. The application will send the initialized message on startup.
   1. You can see this in the logs and in the `Toast` popup.
3. The Flutter counter application increments the counter when the plus button is pressed.
4. The Flutte rcode sends an incremented message every time it increments
   1. You can see this in the logs and in the `Toast` popup.  Look for `received message:`

## Running the Android app

1. Start the android emulator from VS Code
2. (optional) Run the Android studio and open `logcat` to see the android logs
3. Start the application in VSCode by highlighting the `main.dart` and then pressing right mouse to expose the `start debubgging` menu item.
   1. Other ways exist
4. This should launch the application in the android emulator

## TODO

* Run two copies of the flutter module with a swipe operation or a scroll area or something.  See  <https://github.com/flutter/samples/tree/main/add_to_app/multiple_flutters>
