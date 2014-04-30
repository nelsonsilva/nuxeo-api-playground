library nx_repository_browser;

import 'dart:html';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
import 'semantic.dart';

@CustomTag(NXRepositoryBrowser.TAG)
class NXRepositoryBrowser extends NXModule with SemanticUI {

  static const String TAG = "nx-repository-browser";

  String title = "Repository",
         icon = "images/repository.png",
         description = "Browse your repository and discover the properties of your documents.",
         action = "Explore";

  @published String documentId;

  @observable nuxeo.Document document;

  factory NXRepositoryBrowser() => new Element.tag(TAG);

  NXRepositoryBrowser.created() : super.created() {
  }
  documentIdChanged() {
    if (documentId == null) {
      document = null;
    } else {
      NX.doc(documentId).fetch().then((doc) { document = doc; });
    }
  }

  void setupRoutes(route) {
      route.addRoute(
          name: 'home',
          path: '/',
          enter: home);
  }

  home(_) {

  }
}