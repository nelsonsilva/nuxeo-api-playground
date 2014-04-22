library nx_document;

import 'package:nuxeo_automation/client.dart' as nuxeo;
import 'package:polymer/polymer.dart';

@CustomTag("nx-document")
class NXDocument extends PolymerElement {

  @published nuxeo.Document document;

  bool get applyAuthorStyles => true;

  NXDocument.created() : super.created();

  toggleContent() {
    shadowRoot.querySelector("#collapse-content").toggle();
  }
}