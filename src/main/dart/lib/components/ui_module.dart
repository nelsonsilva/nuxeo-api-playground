library module;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:route_hierarchical/client.dart';
export 'package:route_hierarchical/client.dart';
import 'nx_connection.dart';

/// An element which requires a Nuxeo connection
abstract class NXElement extends PolymerElement {

  /// The id of a [NXConnection] element
  @published String connectionId;

  @observable NXConnection connection;

  NXElement.created() : super.created() {
  }

  /// Triggered when ID of the [NXConnection] changes
  connectionIdChanged() {
    connection = document.querySelector("#$connectionId");
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
}

/// Basic information for each Sandbox Module
abstract class NXModule extends NXElement {
  String title, icon, description, link, action;

  String path;
  var router;

  NXModule.created() : super.created();

  bool get preventDispose => true;

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