# Demonstrating embedding a flutter app in an iFrame or via element replacement

Sometimes you want to do an incremental migration from your existing web patter to flutter.
Or you are adding some flutter capability to an existing web application.
This means that you want to run flutter _inside_ or _inserted_ into an existing web application.

## V1

This simulates a dual site by running two web servers, one representing the old site and the other representing the new flutter based web application or component.

* 4001 - represents the existing web site and holds only static content for the example
  * index.html - loads localhost:4002 two ways,
    * as an iFrame an
    * as an element replacement via a loading the flutter_application's `index-embedded.html`
* 4002 - represents the new flutter web site. The flutter app is on the root.
  * index.html - standard flutter
  * index-embedded.html
    * hard coded to replace an HTML element called `replace_this` with the flutter app engine
    * hard coded to know the server it is running on `base`.
  * index-embedded-query.html - not used
    * originally intended to work with a query string to programatically replace a field by name. Retained for future work

## base href

The key to making this work is setting the flutter `base` `href` to the server that the flutter app is running on.
This changes the way flutter creates the URLs used to fetch resources.  The default value inserted at flutter build time is `/`.
You can change the value as part `flutter build web --base-href "http://localhost:4002/"`.

### base href flutter-embedded.html

This runs the same flutter app as an iframe and inside the element tree.
The standard _Flutter_ created `index.html` works fine for standalone.
Running in a div requres severfal changes change to the template created `index.html`

1. Change the way flutter is loaded
2. Find the element we are replacing
3. Change the base href

A new file `index-embedded.html` was created instead of modifying `index.html` so developers can compare the two.
It isn't part of the normal "build web" process so it is hard coded to set the `<base href>`.
Applications that only run inside an element can change the window load behavior and then set the `base` at build time.

The hard coded value in `index-embedded.html`.

```html
  <base href="http://localhost:4002">
```

## V2

V2 wasn't needed because I got this working for the demo.  Originally I tried using query parameters and that didn't work so I hardcoded the path ikn V1