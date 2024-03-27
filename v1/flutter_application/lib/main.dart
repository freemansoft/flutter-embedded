import 'dart:convert';

import 'package:flutter/material.dart';
import "package:universal_html/html.dart" as html;
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  // Be sure to add this line if `PackageInfo.fromPlatform()` is called before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Future<void> initState() async {
    // this object will listen for messages
    html.window.onMessage.listen(
      (html.MessageEvent event) => _listen(event),
    );
    super.initState();
    _postPackageInfo();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      _postActionMessage(
          action: "incremented", actionPayload: {"count": _counter});
    });
  }

  /// Called when a window message event is received
  void _listen(html.MessageEvent event) {
    final eventData = event.data;
    // only increment if we receive the increment command
    // should verify is string and ignore if not
    // debugPrint('${eventData.runtimeType}');
    final data = jsonDecode(eventData as String);
    // Should check origin also
    if (data['action'] == 'increment') {
      debugPrint(
          'flutter received from origin: ${event.origin} data: $eventData');
      _incrementCounter();
    } else {
      // Receive all window messages for that window and domain
      // Ignore the onces we aren't interested in
    }
    // _incrementCounter calls setState
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Send the message to the browser - try and auto detect destinations
}

// Flutter isolates can't run plugins so this can't go in main()
// This is called from build
// This code will get executed after build() because
// the scheduler won't pick up delayed items until then.
Future<void> _postPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  _postActionMessage(action: "started", actionPayload: {
    'appName': packageInfo.appName,
    'packageName': packageInfo.packageName,
    'version': packageInfo.version,
    'buidlNumber': packageInfo.buildNumber
  });
}

void _postActionMessage(
    {required String action, required Map<String, dynamic> actionPayload}) {
  Map<String, dynamic> data = {"action": action};
  data.addAll(actionPayload);

  // use html.window.parent if we are in an iframe
  if (html.window.parent != null) {
    data["location"] = html.window.parent!.location.toString();
    final json = const JsonEncoder().convert(data);
    debugPrint('flutter Message fired: $json to parent.');
    html.window.parent!.postMessage(json, "*");
  }

  // if there is no parent or the parent and window are different
  // This will be true if in iframe but no one will receive it
  if (html.window.parent == null ||
      html.window.parent!.location.toString() !=
          html.window.location.toString()) {
    data["location"] = html.window.location.toString();
    final json = const JsonEncoder().convert(data);
    debugPrint('flutter Message fired: $json to window.');
    // should target a domain instead of global
    html.window.postMessage(json, "*");
  }
}
