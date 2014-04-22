library nx_command_endpoints;

import 'dart:js' as js;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:polymer_expressions/filter.dart' show Transformer;
import 'nx_connection.dart';
import 'ui_filters.dart';
import 'ui_module.dart';

@CustomTag(NXCommandEndpoints.TAG)
class NXCommandEndpoints extends NXModule {

  static const String TAG = "nx-command-endpoints";

  String title = "Command Endpoints",
         icon = "images/command_endpoints.png",
         description = "Discover the Nuxeo service that exposes common actions. Assemble them to create complex business rules and logic, without writing any Java code.",
         action = "Discover";

  // Map with Category => List<Operation>
  final Map<String, List<nuxeo.Operation>> allOperations = toObservable({});

  // Filtered operations
  @observable String filter;
  final Map<String, List<nuxeo.Operation>> operations = toObservable({});

  @observable String selectedOp = null;

  // Tracing
  @observable bool canManageTraces = false;
  @observable bool tracesEnabled = false;


  factory NXCommandEndpoints() => new Element.tag(TAG);

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;


  NXCommandEndpoints.created() : super.created() {
  }

  enteredView() {
    jQuery(".ui.accordion").callMethod('accordion', []);
    // Update the according when the operations change
    onDomChange('#operations', () {
      jQuery(".ui.accordion").callMethod('accordion', []);
    });
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

    NX.registry // Get the op registry
    .then((nuxeo.OperationRegistry registry) {        // Get the ops
      registry.ops.forEach((name, nuxeo.Operation op) {
        var ops = allOperations.putIfAbsent(op.category,() => toObservable([]));
        ops.add(op);
      });

      // Update the filter
      filter = "";

      return registry;
    })
    .catchError((e) {
      connection.alerts.add(
        new Alert.danger("Oh snap!", "Please check the Nuxeo URL and try connecting again.")
      );
      return false;
    });
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

   selectOperation(event, detail, target) {
     router.go("$path.op", {"opId": target.dataset["operation-id"]});
   }

   // Filters and transformers can be referenced as fields.
   final Transformer asID = new StringToID();
}