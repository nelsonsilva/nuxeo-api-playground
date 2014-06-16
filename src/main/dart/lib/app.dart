library app;

import 'dart:html';
import 'package:route_hierarchical/client.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:polymer/polymer.dart';
import 'components/nx_repository_browser.dart';
import 'components/nx_structures_browser.dart';
import 'components/nx_resource_endpoints.dart';
import 'components/nx_command_endpoints.dart';
import 'components/nx_batch_upload.dart';
import 'components/ui_module.dart';
import 'components/nx_connection.dart';

@CustomTag("nx-sandbox-app")
class NXSandboxApp extends PolymerElement {

  @published String connectionId;
  @observable NXConnection connection;

  Map<String, Module> modules = {
    "browser": new RepositoryBrowser(),
    "data": new StructuresBrowser(),
    "resources": new ResourceEndpoints(),
    "commands": new CommandEndpoints(),
    "uploads": new BatchUpload()
  };

  @observable Module module = null;

  var router;

  connectionIdChanged() {
    connection = document.querySelector("#$connectionId");
    // Setup the connectionId for the current module if any
    if ($['module'].children.isNotEmpty) {
      ($['module'].children.first as NXModule).connectionId = connectionId;
    }
  }

  NXSandboxApp.created() : super.created() {

    // Setup Logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogPrintHandler());

    // Setup the root
    router = new Router(useFragment: true);

    // Add a route for each module along with each module's custom subroutes
    modules.forEach((path, Module module) {
      router.root.addRoute(
          name: path,
          preEnter: (_) {
            this.module = modules[path];
          },
          path: '/$path',
          mount: module.mount(path, router));
    });

    // default handler

    router.root.addRoute(name: 'home', defaultRoute: true, path: '/', enter: showHome);

    router.listen();
  }

  void showHome(RouteEvent e) {
    module = null;
  }

  /// Navigate to the home of the selected module
  void navigate(event, detail, target) {
    router.go('${target.dataset['target']}', {});
  }

  void moduleChanged() {
    $['module'].children..clear();
     if (module != null) {
       var el = module.createElement();
       el.connectionId = connectionId;
       $['module'].children.add(el);
     }
  }

}
