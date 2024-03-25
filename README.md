# Demonstrating embedding a flutter app in an iFrame or via element replacement

Sometimes you want to do an incremental migration from your existing web application to flutter flow by flow.
Other times you are adding some flutter capability to an existing web application.
This means that you want to run flutter code _inside_ or _inserted_ into an existing web application.

The topology and technique you choose impacts the complexity of the situtation especially when it comes to browser protections, CORS and cross site scripting.
The simplest to most complex topologies probably are

1. Run a single site containing both apps.
2. Run two sites with the new site proxied through the original site.
3. Run dual site where the original site refers to or loads the new flutter site in iFrames .
4. Run dual site where the original site refers to or loads the new flutter site in an element.

## V1

V1 implments #3 and #4.
It simulates a dual site by running two web servers.
One server is the _old site_ and the other is the _new flutter based web application or component_.

```mermaid
graph TD
  subgraph 4001[Static Site : 4001]
    subgraph staticIndex[index.html]
      iFrame("iFrame
      loads 4002:index.html")

      elementLoad[["Javascript:
      onload() element FLUTTER_DIV_ELEMENT
      loads 4002:index-embedded.html"]]

      elementFlutterDiv("element:
      FLUTTER_DIV_ELEMENT
      Replaced by Flutter index-embedded.html")

      messageReceive[["Javascript:
      widnowEventListener()
      Message Receive"]]
      elementMessage("element:
      MESSAGE_RESULTS_DIV")
    end
  end

  subgraph 4002[Flutter Site : 4002 Flutter Web Package]
      subgraph flutterIndex[index.html]
        flutterIndexLoad[["Javascript:
        load Flutter app
        Replaces iFrame root"]]
      end
      subgraph flutterIndexEmbedded[index-embedded.html]
        flutterIndexLoadEmbedded[["Javascript:
        load Flutter app
        Replace FLUTTER_DIV_ELEMENT"]]
      end
      subgraph flutter[Flutter Web App]
        flutterPostMessage[["Post Message to Window"]]
        counter[[Increment counter]]
        displayWidget
      end
  end

  elementLoad-.loads.->flutterIndexLoadEmbedded
  iFrame-.loads.->flutterIndexLoad

  flutterIndexLoadEmbedded-.loads and starts.->flutter
  flutterIndexLoad-.loads and starts.->flutter
  flutterIndexLoadEmbedded-.replaces element.->elementFlutterDiv
  counter-->flutterPostMessage
  counter--setState()-->displayWidget

  flutterPostMessage--postMessage()-->messageReceive
  messageReceive--appends-->elementMessage


  classDef orange fill:#c63,stroke:#333,stroke-width:2px;
  classDef blue fill:#69c,stroke:#333,strong-width:2px;
  class staticIndex,flutterIndex,flutterIndexEmbedded orange
  class flutter blue

```

* 4001 - represents the existing web site and holds only static content for the example
  * index.html - loads localhost:4002 two ways,
    * as an iFrame via loading the flutter_applications `index.html`
    * as an element replacement via a loading the flutter_application's `index-embedded.html`.  The element id is `FLUTTER_DIV_ELEMENT`.
* 4002 - represents the new flutter web site. The flutter app is on the root.
  * index.html - standard flutter
  * index-embedded.html
    * hard coded to replace an HTML element called `FLUTTER_DIV_ELEMENT` with the flutter app engine
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
Running in a div requires several changes to the Flutter template created `index.html`

1. Add a query to find the element that is being replaced
1. Change the way flutter is loaded in `window.addEventListener('load', function(ev)` and have it replace the element found above.
1. Change the base href that tells Flutter how to access additional resources

`index-embedded.html` is used when embedding.  It was created by copying `index.html` instead of modifying `index.html`.
This lets us run in either mode by selecting the appropriate html file and lets developers compare the two for differences.
Applications that _only_ run inside an element may chose to update `index.html` and set the `base` at build time using standard flutter tooling

* Note: `index-embedded.html` isn't part of the normal "build web" process so it is hard coded to set the `<base href>`.

The hard coded value in `index-embedded.html`.

```html
  <base href="http://localhost:4002">
```

## Demonstrate communication from Flutter to the hosting web page

This program demonstrates Flutter to Javascript communication. It notifies the wrapper via `postMessage()`. The example can be modified for ReactJS or other web frameworks.

A message is sent from the counter to static HTML page hosting both the iFrame and the replaced element.  The embedding HTML page has a Javascript handler that logs received events to a text area in the main page and to the console.

1. For the element replacement, the launch HTML is the same window the element is in.
   1. This shows up as a location of `http://localhost:4001` in the demo in the HTML and the javascript console. This is the static content's location.
1. For the iFrame, the launch HTML is the **parent** window.
   1. This shows up as a location of `Instance of 'minified:a0p'` in the demo in the HTML and the javascript console.
1. For the iFrame, a message is sent into the index.html wrapper that launches flutter.
   1. This shows up as a location of `http://localhost:4002` in the demo.  This is the address of the web server that holds the Flutter application.
   2. We don't see any received message because the Flutter boilerplate HTML has no handler and should stay that way in most places.

## TODO

* Demonstrate message channel communication from the web site to the Flutter Application
* Look at ways of eliminating 'unsafe-inline' and 'unsafe-eval' in ContentSecurityPolicyOptions in `server.dart`.  Left in for now to simplify.
