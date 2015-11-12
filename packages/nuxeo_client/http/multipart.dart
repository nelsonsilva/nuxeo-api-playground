/// Utility functions for parsing Multipart responses
library multipart;

import 'dart:async';
import 'package:mime/mime.dart';
import '../http.dart';

/// [RegExp] for matching a multipart Content-Type header
final RegExp multipartTypeRegex = new RegExp(r'multipart/mixed(; boundary="([\S]+)")?');

/// [RegExp] for extracting the filename from a multipart Content-Disposition header
final RegExp contentDispositionRegex = new RegExp(r'filename=([\w\._-\s]+)');

/// Checks a Content-Type header for multipart
bool isMultipartContent(contentType) => multipartTypeRegex.hasMatch(contentType);

/// Extracts the multipart boundary from a Content-Type header
String getMultipartBoundary(contentType) {
  var match = multipartTypeRegex.firstMatch(contentType);
  return (match.groupCount > 1) ? match.group(2) : null;
}

/// Parses a response and returns a [Future] with a [List] of [Blob]s.
Future<List<Blob>> parse(List<int> data, [boundary]) =>
  new Stream.fromIterable([data])
  .transform(new MimeMultipartTransformer(boundary))
  .map((MimeMultipart multipart) {
        var contentType = multipart.headers['content-type'];
        var filename;
        var contentDisposition = multipart.headers['content-disposition'];
        if(contentDispositionRegex.hasMatch(contentDisposition)) {
          var match = contentDispositionRegex.firstMatch(contentDisposition);
          filename = match.group(1);
        }
        return multipart.first.then((content) {
          return new Blob(filename: filename, content: content, mimetype: contentType);
        });
   })
   .fold([], (l, f) => l..add(f))
   .then(Future.wait);