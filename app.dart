library app;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'model.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:markdown/markdown.dart' show markdownToHtml;

@CustomTag("nx-sandbox-app")
class NXSandboxApp extends PolymerElement with ChangeNotifierMixin {

  Model __$app;
  Model get app => __$app;
  set app(Model value) {
    __$app = notifyPropertyChange(const Symbol('app'), __$app, value);
  }
  

  dynamic __$nuxeoUrl = "http://localhost:8080/nuxeo/site/automation";
  dynamic get nuxeoUrl => __$nuxeoUrl;
  set nuxeoUrl(dynamic value) {
    __$nuxeoUrl = notifyPropertyChange(const Symbol('nuxeoUrl'), __$nuxeoUrl, value);
  }
  

  dynamic __$README = "";
  dynamic get README => __$README;
  set README(dynamic value) {
    __$README = notifyPropertyChange(const Symbol('README'), __$README, value);
  }
  

  bool get applyAuthorStyles => true;

  void created() {
    super.created();
    app = appModel;
  }

  void inserted() {
    _getREADME();
  }

  connect() {

    app.alerts.clear();

    NX = new nuxeo.Client(url: nuxeoUrl);

    NX.login
    .then((login) { app.username = login.username; }) // Get the username
    .then((_) => NX.registry)                         // Get the op registry
    .then((nuxeo.OperationRegistry registry) {        // Get the ops
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
    })
    .catchError((e) {
      app.alerts.add(
        new Alert.danger("Oh snap!", "Please check the Nuxeo URL and try connecting again.")
      );
    });
  }

  disconnect() {
     app.isConnected = false;
     app.categories.clear();
     // TODO - Reload README
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

  getValueWorkaround(key) {
    if (key == const Symbol('app')) return this.app;
    if (key == const Symbol('nuxeoUrl')) return this.nuxeoUrl;
    if (key == const Symbol('README')) return this.README;
    if (key == const Symbol('applyAuthorStyles')) return this.applyAuthorStyles;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('app')) { this.app = value; return; }
    if (key == const Symbol('nuxeoUrl')) { this.nuxeoUrl = value; return; }
    if (key == const Symbol('README')) { this.README = value; return; }
  }
  }
//# sourceMappingURL=app.dart.map