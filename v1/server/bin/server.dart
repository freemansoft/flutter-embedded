import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_helmet/shelf_helmet.dart';

// programatic handler from the template
Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

// programatic demo handler
Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

const Map<String, dynamic> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': '*',
};

ContentSecurityPolicyOptions _cspOptions = ContentSecurityPolicyOptions(
  useDefaults: false,
  reportOnly: false,
  directives: {
    "connect-src": [
      "localhost:4001",
      "localhost:4002",
      "www.gstatic.com",
      "fonts.gstatic.com",
    ],
    "frame-ancestors": [
      "http://localhost:4001",
      "http://localhost:4002",
    ],
    "default-src": [
      "localhost:4001",
      "localhost:4002",
    ],
    "frame-src": [
      "'self'",
      "localhost:4001",
      "localhost:4002",
    ],
    "img-src": [
      "'self'",
      "localhost:4001",
      "localhost:4002",
    ],
    "script-src": [
      "'unsafe-eval'",
      // required for javascript posting messages
      "'unsafe-inline'",
      "localhost:4001",
      "localhost:4002",
      "www.gstatic.com",
    ],
    "script-src-elem": [
      "'unsafe-inline'",
      "localhost:4001",
      "localhost:4002",
      "ajax.googleapis.com",
      "www.gstatic.com",
    ],
    "style-src": [
      "'unsafe-inline'",
      "localhost:4001",
      "localhost:4002",
    ],
  },
  dangerouslyDisableDefaultSrc: false,
);

// Configure the ArgParser with our command line arguments.
// Note that all of these have default values and help
// Use the container port variable if set as the default otherwise 8080
ArgParser _getParser() => ArgParser()
  ..addOption('port',
      abbr: 'i',
      defaultsTo: Platform.environment['PORT'] ?? '8080',
      help: 'Port to listen on - uses container env varaible PORT if set')
  ..addOption('address',
      abbr: 'a',
      defaultsTo: InternetAddress.anyIPv4.address,
      help: 'Address to listen on - uses 0.0.0.0 if non set')
  ..addOption('docroot',
      abbr: 'd',
      defaultsTo: '../public',
      help:
          'static docroot: assuming running from /server "../public" or "../flutter_application/build/web"');

/// Handle the command line arguments and spin up the server
void main(List<String> args) async {
  // Create our configured parser
  final parser = _getParser();

  // Where our arguments end up
  // Defaults are provided provided to Args at configuration time
  int port;
  // Defaults are provided to Args at configuraiton time (usually `0.0.0.0`).
  String ip;
  // shelf can only have one static handler AFAIK
  String docroot;

  try {
    final result = parser.parse(args);
    ip = result['address'] as String;
    port = int.parse(result['port'] as String);
    docroot = result['docroot'] as String;
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln(parser.usage);
    exit(64);
  }

  // Configure http server routes.
  final router = Router(
      notFoundHandler: createStaticHandler(
    docroot,
    defaultDocument: 'index.html',
    listDirectories: true,
  ))
    ..get('/echo/<message>', _echoHandler)
    ..get('/hello', _rootHandler);

  // Configure a pipeline that handles requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_addCorsHeaders())
      .addMiddleware(contentSecurityPolicy(options: _cspOptions))
      .addMiddleware(referrerPolicy(policies: [
        //ReferrerPolicyToken.noReferrer,
        ReferrerPolicyToken.sameOrigin,
        ReferrerPolicyToken.originWhenCrossOrigin,
        ReferrerPolicyToken.origin,
      ]))
      .addMiddleware(_removeXFrameOptionsHeader())
      .addHandler(router.call);

  // For running in containers, we respect the PORT environment variable.
  final server = await shelf_io.serve(handler, ip, port,
      poweredByHeader: "Powered by Joe");
  print('Server listening on port ${server.port} docroot: $docroot');
}

Middleware _removeXFrameOptionsHeader() {
  return createMiddleware(responseHandler: (response) {
    return response.change(headers: {'X-Frame-Options': 'dogfood'});
  });
}

Middleware _addCorsHeaders() {
  return createMiddleware(responseHandler: (response) {
    return response.change(headers: _corsHeaders);
  });
}
