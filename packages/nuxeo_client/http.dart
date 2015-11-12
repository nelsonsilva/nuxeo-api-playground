/**
 * Provides abstractions for an HTTP client for both client and server side uses.
 */
library http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:logging/logging.dart';

final Logger LOG = new Logger("http");

const HEADER_AUTHORIZATION = "Authorization";
const HEADER_CONTENT_TYPE = "content-type";

class MultipartFormData {
  Map<String, dynamic> data = {};
  append(String name, value) {
    data[name] = value;
  }
}

class Blob {
  String filename;
  Uint8List content;
  String mimetype;

  Blob({this.filename: "blob", content, this.mimetype}) {
    if (content is Uint8List) {
      this.content = content;
    } else if (content is String) {
      this.content = new Uint8List.fromList(UTF8.encode(content));
    } else if (content is List<int>) {
      this.content = new Uint8List.fromList(content);
    }
  }

  int get length => content.length;
}

abstract class Response {
  get body;
  get headers;
}

abstract class RequestHeaders {
  set(String name, String value);
  get asMap;
}

abstract class RequestUpload {
}

class RequestEvent {
  String type;
  RequestEvent(this.type);
}

abstract class Request {
  String get method;
  RequestHeaders get headers;
  get upload;
  Future<Response> send([data]);
}

typedef Request Method(Uri uri);

abstract class Client {
  String username, password;
  Uri uri;
  /// [username] and [password] for authentication
  /// [url] is the base URL
  Client({this.username, this.password, String url: ""}) {
    uri = Uri.parse(url);
  }
  Request method(String method, Uri uri, {bool multipart:false});
  Request get(Uri uri) => method("GET", uri);
  Request post(Uri uri, {bool multipart:false}) => method("POST", uri, multipart: multipart);
  Request put(Uri uri) => method("PUT", uri);
  Request delete(Uri uri) => method("DELETE", uri);
}

/**
 * Exception thrown when a [Request] throws an error
 */
class ClientException implements Exception {
  /**
   * A message describing the error.
   */
  final String message;

  /// The [Request] that originated the [ClientException]
  final Request request;

  /// The [Response] we got back from the server
  final Response response;

  /**
   * Creates a new ClientException with an optional error [message].
   */
  const ClientException(this.message, {this.request, this.response});

  String toString() => "ClientException: $message";
}