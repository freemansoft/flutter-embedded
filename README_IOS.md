# Platform Channels

## What the app does

This currently supports unidirectional messaging.

1. The Flutter code posts a message to the `BasicMessageChannel` on startup
2. The Flutter code posts a message to the `BasicMessageChannel` every time the increment butotn is pressed.
3. The iOS code logs received messages via `print()`.  They show up in the XCode log pane.

## Runnning the iOS Simulator

1. Verify you have the target simulator loaded. This is done with XCode. You can find instructions at [adding additional simulators](https://developer.apple.com/documentation/safari-developer-tools/adding-additional-simulators)
2. Build the app in VSCode
3. Open the ios directory in `XCode`
4. Run the application
5. Verify the logs at the bottom of `XCode`

## To Be Implemented

1. Clicking in the ios application and sending that click as an increment command to Flutter.
2. In iOS, converting the received JSON string to a JSON object.
3. Diagrams similar to those for Android