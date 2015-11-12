library http_standalone;

import 'dart:convert' show JSON;
import 'dart:io' as io;
import 'dart:async';
import 'package:http/http.dart' as http;
import '../http.dart' as base;

final LOG = base.LOG;

class Response implements base.Response {
  http.Response _response;

  Response(this._response);

  get body => _response.body;
  get headers => _response.headers;

}

class Headers implements base.RequestHeaders {
  http.BaseRequest _request;
  Headers(this._request);
  set(name, value) => _request.headers[name] = value;
  get asMap => _request.headers;
}


class Request implements base.Request {
  HttpClient _client;
  http.BaseRequest _request;
  bool multipart;

  Request(this._client, String method, Uri uri, {this.multipart: false}) {
    LOG.finest("$method $uri");
    if (multipart) {
      _request = new http.MultipartRequest(method, uri);
    } else {
      _request = new http.Request(method, uri);
    }
  }

  get method => _request.method;
  get upload => null;
  get headers => new Headers(_request);

  Future<Response> send([data]) {
    if (data != null) {

      if (multipart) {
        var multipart = _request as http.MultipartRequest;

        // Convert to html.FormData and html.Blob
        if (data is base.MultipartFormData) {
          data.data.forEach((k, v) {
            if (v is base.Blob) {
              multipart.files.add(new http.MultipartFile.fromBytes(k, v.content,
                  filename: v.filename, contentType: io.ContentType.parse(v.mimetype)));
            }
          });
        }
      } else {

        // Handle blob
        if (data is base.Blob) {
          (_request as http.Request).bodyBytes = data.content;
        } else if (data is Map) {
          (_request as http.Request).body = JSON.encode(data);
        } else {
          (_request as http.Request).body = data;
        }
      }
    }

     return _client.send(_request)
         .then((streamResponse) => http.Response.fromStream(streamResponse))
         .then((response) => new Response(response));
  }

}

class Client extends base.Client {

  HttpClient _client;

  Client(String url, {
      String username,
      String password,
      String realm
  }) : super(url: url, username: username, password: password) {
    var credentials = new io.HttpClientBasicCredentials(username, password);
    _client = new HttpClient(uri, realm, credentials);
  }

  Request method(String method, Uri uri, {bool multipart:false}) => new Request(_client, method, uri, multipart: multipart);
}

// This is a copy of http.IOClient to set the credentials
class HttpClient extends http.BaseClient {

  /// The underlying `dart:io` HTTP client.
  io.HttpClient _inner;

  HttpClient(Uri uri, String realm, io.HttpClientBasicCredentials credentials) {
    _inner = new io.HttpClient()..addCredentials(uri, realm, credentials);
  }

  /// Sends an HTTP request and asynchronously returns the response.
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    var stream = request.finalize();

    return _inner.openUrl(request.method, request.url).then((ioRequest) {
      var contentLength = request.contentLength == null ?
          -1 : request.contentLength;
      ioRequest
          ..followRedirects = request.followRedirects
          ..maxRedirects = request.maxRedirects
          ..contentLength = contentLength
          ..persistentConnection = request.persistentConnection;
      request.headers.forEach((name, value) {
        ioRequest.headers.set(name, value);
      });
      return stream.pipe(ioRequest);
    }).then((response) {
      var headers = {};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      var contentLength = response.contentLength == -1 ?
          null : response.contentLength;
      return new http.StreamedResponse(
          response,
          response.statusCode,
          contentLength: contentLength,
          request: request,
          headers: headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase);
    });
  }

  /// Closes the client. This terminates all active connections. If a client
  /// remains unclosed, the Dart process may not terminate.
  void close() {
    if (_inner != null) _inner.close(force: true);
    _inner = null;
  }

}

