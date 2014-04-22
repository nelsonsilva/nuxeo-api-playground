library module;

import 'dart:js' as js;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:route_hierarchical/client.dart';
export 'package:route_hierarchical/client.dart';
import 'nx_connection.dart';

/// An element which requires a Nuxeo connection
abstract class NXElement extends PolymerElement {

  /// The id of a [NXConnection] element
  @published String connectionId;

  NXConnection connection;

  NXElement.created() : super.created() {
    print("[NXElement] $this created with connectionId $connectionId");
  }

  /// Triggered when ID of the [NXConnection] changes
  connectionIdChanged() {
    connection = document.querySelector("#$connectionId");
    print("$this connection '$connectionId' found ${connection}");
    _trigger(connection.isConnected);
    new PathObserver(connection, 'isConnected').open(_trigger);
  }

  _trigger(bool connected) {
    (connected) ? onConnect() : onDisconnect();
  }

  /// Triggered when the connection is established
  onConnect() {}

  /// Triggered when disconnecting from the server
  onDisconnect() {}

  nuxeo.Client get NX => connection.NX;

  @observable
  bool get isConnected => connection != null && connection.isConnected;

  // Some helper methods
  jQuery(selectorsOrEl) {
    var el = (selectorsOrEl is String) ? shadowRoot.querySelector(selectorsOrEl) : selectorsOrEl;
    return js.context.callMethod(r'$', [el]);
  }

  onDomChange(selectors, handler()) {
    var observer = new MutationObserver((mutations, observer) { handler(); });
    observer.observe(shadowRoot.querySelector(selectors), childList: true);
  }
}

/// Basic information for each Sandbox Module
abstract class NXModule extends NXElement {
  String title, icon, description, action;

  String path;
  var router;

  NXModule.created() : super.created();

  // Store the root router and return the mountFn
  mount(String path, Router router) {
    this.path = path;
    this.router = router;
    return setupRoutes;
  }

  void setupRoutes(Route route);

  navigate(event, detail, target) {
     router.go("${target.dataset["path"]}", {});
  }

  goHome() {
    router.go("home", {});
  }

  goRoot() {
    router.go(path, {});
  }

}