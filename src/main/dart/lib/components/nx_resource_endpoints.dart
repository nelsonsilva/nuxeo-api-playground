library nx_resource_endpoints;

import 'dart:html';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
import 'ui_filters.dart';

@CustomTag(NXResourceEndpoints.TAG)
class NXResourceEndpoints extends NXModule with SearchFilter {

  static const String TAG = "nx-resource-endpoints";

  String title = "Resource endpoints",
         icon = "images/resources_endpoints.png",
         description = "Discover the list of endpoints and see which adapters are available for each of them.",
         action = "Discover";

  get endpoints => ENDPOINTS.values;

  @observable NXResourceEndpoint endpoint;
  @observable String method;

  var input;

  factory NXResourceEndpoints() => new Element.tag(TAG);

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  NXResourceEndpoints.created() : super.created() {
  }

  enteredView() {
      jQuery(".ui.accordion").callMethod('accordion', []);
      // Update the according when the operations change
      onDomChange('#operations', () {
        jQuery(".ui.accordion").callMethod('accordion', []);
      });
    }

  void setupRoutes(Route route) {
   route.addRoute(
     name: 'rest',
     path: '/:endpoint/:method',
     defaultRoute: true,
     enter: (e) {
       endpoint = ENDPOINTS[e.parameters["endpoint"]];
       method = e.parameters["method"];
     });
 }

  select(event, detail, target) {
    var parts = target.dataset["target"].split("/");
    router.go("$path.rest", {"endpoint": parts[0], "method": parts[1]});
  }

  runRequest() {
    var request = endpoint(NX, method);
    request(input);
  }
}

class NXResourceEndpoint {
  final String path;
  final String name;
  final Map<String, NXResourceMethod> methods;
  const NXResourceEndpoint(this.path, this.name, this.methods);
  NXResourceMethod operator[](String k) => methods[k];
  call(nuxeo.Client nx, method) => methods[method](nx.newRequest("$path/$method"));
}

typedef RequestFn(nuxeo.Request request);

class NXResourceMethod {
  RequestFn fn;
  final String name;
  NXResourceMethod(this.name, this.fn);
  call([arg]) => fn(arg);
}

Map<String,NXResourceMethod> _generateMethods(String description) => {
  "get": new NXResourceMethod("Find", (request) => request.fetch),
  "put": new NXResourceMethod("Update", (request) => request.update),
  "post": new NXResourceMethod("Create", (request) => request.create),
  "delete": new NXResourceMethod("Delete", (request) => request.delete)
};

Map<String, NXResourceEndpoint> ENDPOINTS = {
  "path": new NXResourceEndpoint("path", "Path", _generateMethods(" a document by its path")),
  "id": new NXResourceEndpoint("id", "ID", _generateMethods(" a document by its id")),
  "user": new NXResourceEndpoint("user", "User", _generateMethods(" a user by its id")),
  "group": new NXResourceEndpoint("group", "Group", _generateMethods(" a group by its id")),
  "directory": new NXResourceEndpoint("directory", "Directory", _generateMethods(" a group by its id"))
};