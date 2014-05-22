library nx_connection;

import 'dart:async';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'semantic.dart';

@CustomTag(NXConnection.TAG)
class NXConnection extends PolymerElement with SemanticUI {

  static const String TAG = "nx-connection";

  /// Global Nuxeo Automation Client instance
  nuxeo.Client NX;

  @observable bool isConnected = false;

  @observable String username = "Administrator";
  @observable String password = "Administrator";
  @observable String avatar = "https://avatars0.githubusercontent.com/u/6028";

  @observable var nuxeoUrl = "http://demo.nuxeo.com/nuxeo"; // "http://localhost:8080/nuxeo";

  // Tracing
  @observable bool canManageTraces = false;
  @observable bool tracesEnabled = false;

  // Error messages
  final List<Alert> alerts = toObservable([]);

  NXConnection.created() : super.created() {
  }

  nuxeoUrlChanged() {
    //TODO(nfgs) Update the server URL
  }

  /// Connect to the server and return the [nuxeo.OperationRegistry]
  Future<nuxeo.Client> connect() {

    alerts.clear();

    if (isConnected) { // We're already connected return
      return new Future.value(NX);
    }

    NX = new nuxeo.Client(url: nuxeoUrl, username: username, password: password, schemas: ["*"]);

    return NX.login()
    .then((login) {

      isConnected = true;

      // Get the username
      username = login.username;

      return NX;
     })
    .catchError((e) {
      alerts.add(
        new Alert.error("Please check the Nuxeo URL and try connecting again.")
      );
    });
  }

  isConnectedChanged() {

    async((_) {
      dropdown('.ui.dropdown');
    });

    // Check if we can toggle tracing if so set the default traing level
   _checkCanManageTraces().then((yes) { if(yes) tracesEnabledChanged(); });
  }

  disconnect() {
     isConnected = false;
  }

  /*
   * Tracing
   */

  /// Checks if we can manage traces
  Future<bool> _checkCanManageTraces() =>
      NX.httpClient.get(Uri.parse("$nuxeoUrl/site/automation/doc/traces?opId=")).send()
      .then((res) => canManageTraces = (res.body != "You can not manage traces"));

  tracesEnabledChanged() {
    toggleTraces(tracesEnabled);
  }

  /// Toggle traces
  Future<bool> toggleTraces(flag) => NX.op("Traces.ToggleRecording").params({"enableTrace": flag})();

  Future<String> getTrace(op) =>
    NX.httpClient.get(Uri.parse("$nuxeoUrl/site/automation/doc/traces?opId=$op")).send()
    .then((res) => res.body);
}

class Alert {
  String style;
  String message;
  Alert.error(this.message) : style = "error";
}