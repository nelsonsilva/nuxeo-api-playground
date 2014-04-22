library nx_repository_browser;

import 'dart:html';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
//import 'ui_sidebar.dart';

@CustomTag(NXRepositoryBrowser.TAG)
class NXRepositoryBrowser extends NXModule {

  static const String TAG = "nx-repository-browser";

  String title = "Repository",
         icon = "images/repository.png",
         description = "Browse your repository and discover the properties of your documents.",
         action = "Explore";

  @published List selectedDocuments = toObservable([]);

  @published nuxeo.Document document;

  factory NXRepositoryBrowser() => new Element.tag(TAG);

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  NXRepositoryBrowser.created() : super.created() {
  }

  selectedDocumentsChanged() {
    if (selectedDocuments.isEmpty) {
      document = null;
    } else {
      NX.doc(selectedDocuments.first).fetch().then((doc) { document = doc; });
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