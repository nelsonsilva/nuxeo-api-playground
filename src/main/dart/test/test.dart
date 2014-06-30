library nuxeo_api_playground.test;

import 'dart:async';
import 'dart:html';

import 'package:nuxeo_api_playground/app.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/html_config.dart';
import 'package:unittest/unittest.dart';

import 'junit.dart';

part 'src/test_content_browser.dart';
part 'src/test_login.dart';
part 'src/util.dart';

// The app instance
NXSandboxApp app;

/// Navigate to a module
go(module) =>  app.router.go(module, {});

void main() {
  //useHtmlConfiguration();
  useJUnitConfiguration();

  initPolymer();

  Polymer.onReady.then(((_) {
    app = document.querySelector('#app');
    testLogin();
    testContentBrowser();
  }));

}




