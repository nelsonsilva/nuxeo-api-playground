library nuxeo_automation_client;

import 'dart:async';
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';
import 'http.dart' as http;
import 'client.dart' as nx;

part 'src/rpc/request.dart';

/// Logs in to the Nuxeo server and returns a [Login]
Future<nx.Login> login(Uri rpcUri, http.Client client) {
  var loginUri = Uri.parse("${rpcUri}/login");
  var request = client.post(loginUri);

  // Set the content type
  request.headers.set(http.HEADER_CONTENT_TYPE, nx.CTYPE_REQUEST_NOCHARSET);

  return request.send()
      .catchError((e) {
        throw new nx.ClientException(e.message);
      })
      .then((response) {
        var json = JSON.decode(response.body);
        return new nx.Login.fromJSON(json);
      });
  }