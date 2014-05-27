library nx_connection;

import 'dart:async';
import 'dart:math' as Math;

import 'package:nuxeo_api_playground/cookies.dart';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'semantic.dart';

@CustomTag(NXConnection.TAG)
class NXConnection extends PolymerElement with SemanticUI {

  static const String TAG = "nx-connection";

  static const NX_AUTHENTICATION_TOKEN = "X-Authentication-Token";
  static const NX_URL_COOKIE = "Nuxeo-URL";

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
    // Check if we have any token stored as a cookie
    String token = cookies[NX_AUTHENTICATION_TOKEN];
    if (token != null) {
      nuxeoUrl = cookies[NX_URL_COOKIE];
      NX = new nuxeo.Client(url: nuxeoUrl, schemas: ["*"], headers: {NX_AUTHENTICATION_TOKEN: token});
      _login();
    }
  }

  nuxeoUrlChanged() {
    //TODO(nfgs) Update the server URL
  }

  /// Connect to the server
  connect() {

    alerts.clear();

    NX = new nuxeo.Client(url: nuxeoUrl, username: username, password: password, schemas: ["*"]);

    _login().then((_) {
      // Try to get a token and if succeed store it as a cookie along with the URL
      var deviceId = "device-${new Math.Random().nextInt(999)}";
      _getToken("Nuxeo API Playground", deviceId, deviceId).then((token) {
        cookies[NX_AUTHENTICATION_TOKEN] = token;
        cookies[NX_URL_COOKIE] = nuxeoUrl;
      });
    });
  }

  _login() => NX.login()
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

  /// Get a token that can be used for authentication
  Future<String> _getToken(String applicationName, String deviceId, String deviceDescription, {String permission:"rw"}) {
    var p = "applicationName=$applicationName&deviceId=$deviceId&deviceDescription=$deviceDescription&permission=$permission";
    var request = NX.httpClient.get(Uri.parse("$nuxeoUrl/authentication/token?$p"));
    request.headers.set("X-No-Basic-Header", "true");
    return request.send().then((response) => response.body);
  }

  isConnectedChanged() {

    async((_) {
      dropdown('.ui.dropdown');
    });

    // Check if we can toggle tracing if so set the default traing level
   _checkCanManageTraces().then((yes) { if(yes) tracesEnabledChanged(); });
  }

  disconnect() {
    cookies.remove("X-Authentication-Token");
    cookies.remove("Nuxeo-URL");
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