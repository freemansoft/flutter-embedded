import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart' as shelf_proxy;
import 'package:http/http.dart' as http;

/// prunes off the first part of a server request
Handler pruningProxyHandler(Object url,
    {http.Client? client, String? proxyName}) {
  var wrapped =
      shelf_proxy.proxyHandler(url, client: client, proxyName: proxyName);

  return (serverRequest) async {
    Request newRequest = serverRequest.change(path: "flutter_application");
    return wrapped(newRequest);
  };
}
