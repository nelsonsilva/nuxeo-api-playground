library app;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'model.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:markdown/markdown.dart' show markdownToHtml;

@CustomTag("nx-sandbox-app")
class NXSandboxApp extends PolymerElement with ObservableMixin {

  @observable Model app;

  @observable var nuxeoUrl = "http://localhost:8080/nuxeo/site/automation";

  @observable var README = "";

  bool get applyAuthorStyles => true;

  void created() {
    super.created();
    app = appModel;
  }

  void inserted() {
    _getREADME();
  }

  connect() {

    NX = new nuxeo.Client(url: nuxeoUrl);

    NX.registry.then((nuxeo.OperationRegistry registry) {
      app.isConnected = true;
      registry.ops.forEach((name, nuxeo.Operation op) {
        var category = app.categories.firstWhere((c) =>
            c.name == op.category,
            orElse: () {
              var c = new NXOperationCategory(op.category);
              app.categories.add(c);
              return c;
            });
        category.operations.add(op);
      });
    });
  }

  toggleCategory(event, detail, target) {
    var id = int.parse(target.dataset["category-id"]);
    var category = app.categories.firstWhere((c) => c.id == id);
    category.toggle();
  }

  selectOperation(event, detail, target) {
    app.selectedOp = target.dataset["operation-id"];
  }

  _getREADME() {
    HttpRequest.getString("README.md")
      .then((str) {
        shadowRoot.query("#readme").appendHtml(markdownToHtml(str));
      })
      .catchError((e) => print(e));
  }
}