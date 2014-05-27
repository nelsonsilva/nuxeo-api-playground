library nx_command_endpoints;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer_expressions/filter.dart' show Transformer;
import 'nx_connection.dart';
import 'ui_filters.dart';
import 'ui_module.dart';
import 'semantic.dart';

@CustomTag(NXCommandEndpoints.TAG)
class NXCommandEndpoints extends NXModule with SearchFilter, SemanticUI {

  static const String TAG = "nx-command-endpoints";

  String title = "Command Endpoints",
         icon = "command_endpoints.png",
         description = "Discover the Nuxeo service that exposes common actions. Assemble them to create complex business rules and logic, without writing any Java code.",
         action = "Discover";

  // Map with Category => List<Operation>
  final Map<String, List<nuxeo.Operation>> operations = toObservable({});

  @observable String selectedOp = null;

  // SearchFilter
  @observable String searchTerm = '';
  @observable String searchFilter = '';

  // Tracing
  @observable bool canManageTraces = false;
  @observable bool tracesEnabled = false;

  factory NXCommandEndpoints() => new Element.tag(TAG);

  NXCommandEndpoints.created() : super.created() {
  }

  @override
  void setupRoutes(Route route) {
    route.addRoute(
        name: 'op',
        path: '/:opId',
        defaultRoute: true,
        enter: (e) {
          selectedOp = e.parameters["opId"];
        }
    );
  }

  @override
  onConnect() {
    operations.clear();
    NX.registry // Get the op registry
    .then((nuxeo.OperationRegistry registry) {        // Get the ops
      registry.ops.forEach((name, nuxeo.Operation op) {
        var ops = operations.putIfAbsent(op.category,() => toObservable([]));
        ops.add(op);
      });

      async((_) { accordion(".ui.accordion"); });

      notifyPropertyChange(#categories, null, categories);
    })
    .catchError((e) {
      connection.alerts.add(
        new Alert.error("Failed to retrieve operations.")
      );
      return false;
    });
  }

  // Only show categories with operations
  get categories => operations.keys.where((c) => filter(searchFilter)(operations[c]).isNotEmpty);

  @override
  String labelFor(item) => item.label;

  searchFilterChanged() {
    notifyPropertyChange(#categories, null, categories);
    async((_) { accordion(".ui.accordion"); });
  }

  selectOperation(event, detail, target) {
    router.go("$path.op", {"opId": target.dataset["operation-id"]});
  }

  // Filters and transformers can be referenced as fields.
  final Transformer asID = new StringToID();
}