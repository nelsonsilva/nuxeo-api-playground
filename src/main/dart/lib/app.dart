library app;

import 'package:route_hierarchical/client.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:polymer/polymer.dart';
import 'components/nx_repository_browser.dart';
import 'components/nx_structures_browser.dart';
import 'components/nx_resource_endpoints.dart';
import 'components/nx_command_endpoints.dart';
import 'components/ui_module.dart';

@CustomTag("nx-sandbox-app")
class NXSandboxApp extends PolymerElement {

  @published String connectionId;

  Map<String, NXModule> modules = {
    "browser": new NXRepositoryBrowser(),
    "data": new NXStructuresBrowser(),
    "resources": new NXResourceEndpoints(),
    "commands": new NXCommandEndpoints()
  };

  @observable NXModule module = null;

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  @override bool get applyAuthorStyles => true;

  var router;

  connectionIdChanged() {
    // Setup the connectionId for all the modules
    modules.values.forEach((NXModule m) { m.connectionId = connectionId; });
  }

  NXSandboxApp.created() : super.created() {

    // Setup Logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogPrintHandler());

    // Setup the root
    router = new Router(useFragment: true);


    // Add a route for each module along with each module's custom subroutes
    modules.forEach((path, module) {
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
       $['module'].children.add(module);
     }
  }

}
