library nx_operation;

import 'dart:convert' show JSON;
import 'ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_client/client.dart' as nuxeo;
import 'semantic.dart';

class NxOperationMethod extends Observable {
  String name = "run";
  @observable var input;
  @observable var inputType;
  @observable var outputType;

  NxOperationMethod(nuxeo.OperationMethod method) {
    inputType = method.input;
    outputType = method.output;
  }
}

class NxOperationParamValue implements Comparable<NxOperationParamValue> {

  nuxeo.OperationParam _param;
  @observable var value;

  NxOperationParamValue(this._param) {
    value = (_param.values != null && _param.values.isNotEmpty) ? _param.values.first : null;
  }

  String get name => _param.name;

  String get dataType => _param.type;

  String get widget => (_param.name == 'xpath') ? "xpath" : (_param.widget == null) ? "text" : _param.widget;

  bool get required => _param.isRequired;

  bool get isValid => !required || (required && value != null);

  List get options => _param.values;

  int compareTo(NxOperationParamValue other) => _param.order - other._param.order;
}

@CustomTag("nx-operation")
class NXOperation extends NXElement with SemanticUI {

  @published String opid;
  nuxeo.Operation _op;
  @observable nuxeo.OperationRequest opRequest;
  @observable var opResponse;

  @observable String name;
  @observable String label;
  @observable String description;
  final List<NxOperationParamValue> params = toObservable([]);

  final List<NxOperationMethod> methods = toObservable([]);
  @observable NxOperationMethod method;

  final List errors = toObservable([]);

  NXOperation.created() : super.created() {
  }

  enteredView() {
    accordion(".ui.accordion");

    /* Update the according when the operations change
     onDomChange('#input', () {
       jQuery(".ui.dropdown").callMethod('dropdown', []);
     });*/
  }

  void opidChanged() {
    if (isConnected) {
      _fetchOp();
    }
  }

  @override
  onConnect() {
    _fetchOp();
  }

  void _fetchOp() {

    // Check if we have already fetched the current op
    if (opid == null || (_op != null && _op.id == opid)) {
      return;
    }

    // Clear the result area
    var results = shadowRoot.querySelector("#result");
    if (results != null) {
      results.children.clear();
    }

    // Clear the errors
    errors.clear();
    // Reset the selected method
    method = null;
    opRequest = opResponse = null;

    NX.registry.then((registry) {
      _op = registry[opid];
      name = _op.id;
      label = _op.label;
      description = _op.description;

      // Setup the parameters
      params.clear();
      params.addAll(_op.params.values.map((p) => new NxOperationParamValue(p)));
      params.sort();

      // Setup the parameters
      methods.clear();
      methods.addAll(_op.methods.map((m) => new NxOperationMethod(m)));
      method = methods.first;

    });
  }

  void callOp(evt) {
    // don't submit the form
    evt.stopImmediatePropagation();
    evt.preventDefault();

    var valid = shadowRoot.querySelectorAll("nx-widget").every((_) => _.valid);

    if (!valid) {
      return;
    }

    // Clear previous results and errors
    errors.clear();

    // Setup the parameters
    var opParams = {};
    params
    .where((p) => p.value != null) // only those that are not null)
    .forEach((param) {
      opParams[param.name] = param.value;
    });

    // Call the op
    opRequest = NX.op(_op.id)
    .input(method.input)
    .params(opParams);

    opRequest.execute()
    .then((res) { opResponse = res; })
    .catchError((e) {
      if (e is nuxeo.ClientException) {

        // Store the response
        opResponse = e.response;

        var message = e.message;
        // Check if this is JSON and we can extract just the message
        try {
          var json = JSON.decode(e.response.body);
          if (json["message"] != null) {
            message = json["message"];
          }
        } on FormatException catch(e) {

        }
        errors.add(message);
      }
    });
  }

}