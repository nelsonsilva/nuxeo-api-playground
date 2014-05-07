library nx_resource_endpoints;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
import 'ui_filters.dart';
import '../swagger.dart' as swagger;
import 'semantic.dart';

const RESOURCE_ENDPOINTS = const ["path", "id", "directory", "user", "group"];

class NxParameterValue extends Observable {

  swagger.Parameter _param;
  @observable var value;

  NxParameterValue(this._param);

  String get name => _param.name;
  String get dataType => _param.dataType;
  String get description => _param.description;
  String get type => _param.type;

  bool get isPathParam => _param.isPathParam;
  bool get isHeaderParam => _param.isHeaderParam;
  bool get isBodyParam => _param.isBodyParam;

  bool get required => _param.required;

  bool get isValid => !required || (required && value != null);

  String get widget {

    // We use the type to specify the field of the document we want to use
    if (name == 'docPath') return 'path';
    if (name == 'docId') return 'uid';

    if (isBodyParam) return 'textarea';

    if (dataType == 'string') return 'text';

    return dataType;
  }
}

@CustomTag(NXResourceEndpoints.TAG)
class NXResourceEndpoints extends NXModule with SemanticUI, SearchFilter {

  static const String TAG = "nx-resource-endpoints";

  String title = "Resource endpoints",
         icon = "images/resources_endpoints.png",
         description = "Discover the list of endpoints and see which adapters are available for each of them.",
         action = "Discover";

  final Map<String, swagger.Resource> endpoints = toObservable({});

  @observable String endpointKey;
  @observable String method;

  @observable swagger.Resource endpoint;
  @observable swagger.Operation operation;

  final List<NxParameterValue> params = toObservable([]);

  @observable nuxeo.Request request;
  @observable var response;
  final List errors = toObservable([]);

  // SearchFilter
  @observable String searchTerm = '';
  @observable String searchFilter = '';

  factory NXResourceEndpoints() => new Element.tag(TAG);

  NXResourceEndpoints.created() : super.created() {

  }


  /// Triggered when the connection is established
  onConnect() {
    endpoints.clear();

    Future.wait(
     RESOURCE_ENDPOINTS.map((resourceKey) {
      var request = NX.newRequest("/doc/$resourceKey.json");

      // Execute the method (does not handle the response)
      return request.method("GET").execute()
      .then((response) {
        var json = JSON.decode(response.body);
        var listing = new swagger.Listing.fromJSON(json);
        // Just use the first resource declaration for now
        var resource = listing.resources.first;
        endpoints[resourceKey] = resource;
      });
    }))
    // After everything is loaded
    .then((_) {
      endpointKeyChanged();
      methodChanged();
      // let's setup the accordion
      async((_) => accordion("#endpoints"));
    });

  }

  void setupRoutes(Route route) {
   route.addRoute(
     name: 'rest',
     path: '/:endpoint/:method',
     defaultRoute: true,
     enter: (e) {
       endpointKey = e.parameters["endpoint"];
       method = e.parameters["method"];
       endpointKeyChanged(); // force triggering endpointKeyChanged
     });
 }

  endpointKeyChanged() {
    if (endpointKey == null) {
      endpoint = null;
    } else {
      endpoint = endpoints[endpointKey];
    }
    methodChanged();// force triggering methodChanged
  }

  methodChanged() {
    if (endpoint == null || method == null) {
      operation = null;
    } else {
      operation = endpoint.operations.where((o) => o.method == method).first;
    }
    operationChanged(); // force triggering operationChanged
  }

  operationChanged() {
    // Setup the parameters
    params.clear();

    // Add all except header params
    if (operation != null) {
      params.addAll(operation.parameters.where((p) => !p.isHeaderParam).map((p) => new NxParameterValue(p)));
    }

    // Clear request and response
    _reset();

    // Setup the options
    async((_) => accordion("#options"));
  }

  select(event, detail, target) {
    var parts = target.dataset["target"].split("/");
    router.go("$path.rest", {"endpoint": parts[0], "method": parts[1]});
  }

  runRequest(evt) {

    // don't submit the form
    evt.stopImmediatePropagation();
    evt.preventDefault();

    // Clear request and response
    _reset();

    var valid = shadowRoot.querySelectorAll("nx-widget").every((_) => _.valid);

    if (!valid) {
      errors.add("Invalid form values!");
      return;
    }

    String path = endpoint.path;

    // replace parameters
    params.where((p) => p.isPathParam).forEach((param) {
      path = path.replaceAll("{${param.name}}", (param.value == null)? "" : param.value);
    });

    var bodyParam = params.where((p) => p.isBodyParam);

    var body = (bodyParam.isEmpty) ? null : bodyParam.first.value;

    request = NX.newRequest("$path");

    // Call the op using 'execute' which does not handle the response
    request.method(operation.method).execute(body)
    .then((res) { response = res; })
     .catchError((e) {
       var message = (e is Exception)? e.message : e.toString();
       errors.add(message);
     });
  }

  get capitalize => new Capitalize();

  /// Clear request, response and errors
  _reset() {
    response = null;
    request = null;
    errors.clear();
  }
}