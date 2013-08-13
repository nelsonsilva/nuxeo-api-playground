library app_bootstrap;

import 'package:polymer/polymer.dart';
import 'dart:mirrors' show currentMirrorSystem;
import 'index.html.dart' as userMain;

import 'nx_operation.dart' as i0;
import 'app.dart' as i1;
import 'nx_widget.dart' as i2;

void main() {
  initPolymer([
      'nx_operation.dart',
      'app.dart',
      'nx_widget.dart',
    ],
    userMain.main,
    currentMirrorSystem().findLibrary(const Symbol('app_bootstrap'))
        .first.uri.toString());
}
