/**
 * Provides a Client Library for Nuxeo API.
 *
 * ## Installing ##
 *
 * Use [pub][] to install this package. Add the following to your `pubspec.yaml`
 * file.
 *
 *     dependencies:
 *       nuxeo_client: any
 *
 * Then run `pub install`.
 *
 * ## Quick Start ##
 *
 *
 * This library should not be imported directly.
 * You should use either `browser_client` or `standalone_client`
 * as these provide proper abstractions (see [http_client](http_client.html)).
 *
 * * For browser applications use:
 *
 *     `import 'package:nuxeo_client/browser_client.dart' as nuxeo;`
 *
 * * For standalone/console applications use:
 *
 *     `import 'package:nuxeo_client/standalone_client.dart' as nuxeo;`
 *
 * * Then create your [Client] instance:
 *
 *     `var nx = new nuxeo.Client();`
 *
 *
 * For more information, see the
 * [nuxeo_client package on pub.dartlang.org](http://pub.dartlang.org/packages/nuxeo_client).
 *
 * [pub]: http://pub.dartlang.org
 */
library nuxeo_client;

import 'dart:async';
import 'dart:collection';
import 'dart:math' as Math;
import 'dart:convert' show JSON;
@MirrorsUsed(metaTargets: 'EntityType')
import 'dart:mirrors';
import 'package:logging/logging.dart';
import 'http.dart' as http;
export 'http.dart' show ClientException;
import 'rest.dart' as rest;
export 'rest.dart' show RemoteDocument, Request;
import 'automation.dart' as rpc;
export 'automation.dart' show OperationRequest;

part 'src/adapter.dart';
part 'src/login.dart';
part 'src/request.dart';
part 'src/operation.dart';
part 'src/uploader.dart';
part 'src/registry.dart';
part 'src/document.dart';

/// Nuxeo [Client] Defaults
class DEFAULT {
  static const USERNAME = "Administrator";
  static const PASSWORD = "Administrator";
  static const TIMEOUT = const Duration(seconds: 3);
  static const SCHEMAS = const [];
  static const REPOSITORY = "default";
}

/**
 * Nuxeo client.
 */
abstract class Client {

  static final LOG = new Logger("nuxeo.automation");

  /// The [http.Client] to use
  http.Client httpClient;

  String username, password;
  Uri _rpcUri, _restUri;
  Duration timeout;
  String repositoryName;
  List<String> schemas;
  Map headers;

  Introspection config;

  Client(this.httpClient, {this.timeout, this.schemas, this.repositoryName, this.headers}) {
    _rpcUri = Uri.parse("${httpClient.uri}/site/automation");
    _restUri = Uri.parse("${httpClient.uri}/api/v1");

    config = new Introspection(this);

    if (headers == null) {
      headers = {};
    }
  }

  /* REST */
  rest.Request newRequest(String path, {String repo, Duration execTimeout}) =>
        new rest.Request(Uri.parse("$_restUri/$path"), this);

  rest.Request doc(String uidOrPath, {String repo}) {
    var path;
    if (uidOrPath.startsWith("/")) {
      if (uidOrPath.length > 1 && uidOrPath.endsWith("/")) {
        uidOrPath = uidOrPath.substring(0, uidOrPath.length - 1);
      }
      path = "path$uidOrPath";
    } else {
      path = "id/$uidOrPath";
    }
    return newRequest(path, repo: repo);
  }

  rest.Request user(String userId, {String repo}) => newRequest("/user/$userId", repo: repo);

  rest.Request group(String groupId, {String repo}) => newRequest("/group/$groupId", repo: repo);

  rest.Request directory(String directoryId, {String repo}) => newRequest("/directory/$directoryId", repo: repo);


  /* RPC */

  /// Creates an [OperationRequest] for the [Operation] with the given [id].
  ///
  /// You can also specify an [execTimeout] and an [uploadTimeout].
  rpc.OperationRequest op(String id, {
    execTimeout: const Duration(seconds: 30),
    uploadTimeout: const Duration(minutes: 20)
  }) => new rpc.OperationRequest(id, _rpcUri, this);

  Future<OperationRegistry> get registry => OperationRegistry.get(_rpcUri, httpClient);

  /// Logs in to the Nuxeo server and returns a [Login]
  Future<Login> login() => rpc.login(_rpcUri, httpClient);

}

/// Doctypes Introspection API
class Introspection {

  Client client;

  Introspection(this.client);

  get uri => "${client._restUri}/config";

  fetch(path) => client.httpClient.get(Uri.parse("$uri/$path")).send();

  Future<http.Response> types([String doctype = ""]) => fetch("types/$doctype");

  Future<http.Response> schemas([String schema = ""]) => fetch("schemas/$schema");

  Future<http.Response> facets([String facet = ""]) => fetch("facets/$facet");
}
