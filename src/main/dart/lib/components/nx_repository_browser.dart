library nx_repository_browser;

import 'dart:html';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
import 'semantic.dart';

class RepositoryBrowser extends Module {
  String title = "Repository",
         icon = "repository.png",
         description = "Browse your repository and discover the properties of your documents.",
         action = "Explore",
         tag = NXRepositoryBrowser.TAG;
}

@CustomTag(NXRepositoryBrowser.TAG)
class NXRepositoryBrowser extends NXModule with SemanticUI {

  static const String TAG = "nx-repository-browser";

  @published String documentId;

  @observable nuxeo.Document document;

  NXRepositoryBrowser.created() : super.created() {
  }

  documentIdChanged() {
    if (documentId == null) {
      document = null;
    } else {
      NX.doc(documentId).fetch().then((doc) { document = doc; });
    }
  }
}