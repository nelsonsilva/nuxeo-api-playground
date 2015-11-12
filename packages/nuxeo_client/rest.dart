library nuxeo_rest_client;

import 'dart:convert' show JSON;
@MirrorsUsed(targets: nx.Document)
import 'dart:mirrors';

import 'package:logging/logging.dart';

import 'client.dart' as nx;
import 'http.dart' as http;

part 'src/rest/request.dart';
part 'src/rest/document.dart';