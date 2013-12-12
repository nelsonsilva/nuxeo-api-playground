library app;

import 'dart:async';
import 'dart:html';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:route/client.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_collapse/polymer_collapse.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;
import 'ui_filters.dart';
import 'model.dart';

@CustomTag("nx-sandbox-app")
class NXSandboxApp extends PolymerElement {

  @observable bool isConnected = false;

  // Map with Category => List<Operation>
  final Map<String, List<nuxeo.Operation>> allOperations = toObservable({});

  // Filtered operations
  @observable String filter;
  final Map<String, List<nuxeo.Operation>> operations = toObservable({});

  @observable String selectedOp = null;

  String selectedOpCategory = null;

  @observable String username;

  final List<Alert> alerts = toObservable([]);

  @observable var nuxeoUrl = NUXEO_URL;

  @observable var README = "";

  // Tracing
  @observable bool canManageTraces = false;
  @observable bool tracesEnabled = false;

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  final UrlPattern opUrl = new UrlPattern(r'(.*)#(.*)');

  NXSandboxApp.created() : super.created() {

    // Setup Logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogPrintHandler());

    // Setup the root
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) {}) // default handler
    ..addHandler(opUrl, (String path) {
      var op = opUrl.parse(path)[1];

      // If the url contains an op let's connect and select that op
      connect().then((registry) {
        if (registry[op] == null) { // Op not found
          alerts.add(new Alert.danger("Not found!", "No $op operation found!"));
          selectedOp = null;
        } else { // Found the op, let's toggle it's category
          selectedOp = op;
          allOperations.forEach((c, ops) {
            if (ops.any((op) => op.id == selectedOp)) {
              selectedOpCategory = c;
              return;
            }
          });
        }
      });
    })
    ..listen();
  }

  // Filters and transformers can be referenced as fields.
  final Transformer asID = new StringToID();

  void ready() {
    _getREADME();
  }

  /// Connect to the server and return the [nuxeo.OperationRegistry]
  Future<nuxeo.OperationRegistry> connect() {

    alerts.clear();

    if (isConnected) { // We're already connected return the registry
      return NX.registry;
    }

    //TODO(nfgs) - Remove these from the model
    NX = new nuxeo.Client(url: nuxeoUrl);
    NUXEO_URL = nuxeoUrl;

    return NX.login
    .then((login) { username = login.username; }) // Get the username
    .then((_) => NX.registry)                         // Get the op registry
    .then((nuxeo.OperationRegistry registry) {        // Get the ops
      isConnected = true;
      registry.ops.forEach((name, nuxeo.Operation op) {
        var ops = allOperations.putIfAbsent(op.category,() => toObservable([]));
        ops.add(op);
      });

      // Update the filter
      filter = "";

      // Check if we can toggle tracing if so set the default traing level
      _checkCanManageTraces().then((yes) { if(yes) tracesEnabledChanged(); });

      return registry;
    })
    .catchError((e) {
      alerts.add(
        new Alert.danger("Oh snap!", "Please check the Nuxeo URL and try connecting again.")
      );
    });
  }

  disconnect() {
     isConnected = false;
     operations.clear();
     selectedOp = null;
     // TODO - Reload README
  }

  get categories => operations.keys;

  filterChanged() {

    var oldValue = categories;
    operations.clear();
    allOperations.forEach((category, ops) {
      ops.forEach((op) {
        if (op.label.toLowerCase().contains(filter.toLowerCase())) {
          operations.putIfAbsent(category,() => []);
          operations[category].add(op);
        }
      });
    });
    notifyPropertyChange(#categories, oldValue, categories);
  }

  toggleCategory(event, detail, target) {
    _toggleCategory(target.dataset["category-id"]);
  }

  HtmlElement getCategoryElement(c) {
    var id = asID.forward(c);
    return shadowRoot.querySelector("#category-$id");
  }

  _toggleCategory(c) {
    var id = asID.forward(c);
    PolymerCollapse category = shadowRoot.querySelector("#collapse-$id");
    category.enteredView();
    category.toggle();
  }

  selectOperation(event, detail, target) {
    selectedOp = target.dataset["operation-id"];
  }

  _getREADME() {
    HttpRequest.getString("README.md")
      .then((str) {
        shadowRoot.querySelector("#readme").appendHtml(markdownToHtml(str));
      })
      .catchError((e) => print(e));
  }

  /*
   * Tracing
   */

  /// Checks if we can manage traces
  Future<bool> _checkCanManageTraces() =>
      HttpRequest.getString("$NUXEO_URL/site/automation/doc/traces?opId=", withCredentials: true)
      .then((res) => canManageTraces = (res != "You can not manage traces"));

  tracesEnabledChanged() {
    toggleTraces(tracesEnabled);
  }

  /// Toggle traces
  Future<bool> toggleTraces(flag) => NX.op("Traces.ToggleRecording")(params: {"enableTrace": flag});

  Future<String> getTrace(op) =>
    HttpRequest.getString("$NUXEO_URL/site/automation/doc/traces?opId=$op", withCredentials: true);
}