library nx_operation;

import 'dart:async';
import 'dart:html';
import 'model.dart';
import 'nx_document.dart';
import 'ui_filters.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/client.dart' as nuxeo;
import 'package:nuxeo_automation/http.dart' as http;

class NxOperationMethod extends Observable {
  nuxeo.OperationMethod _method;
  String name = "run";
  @observable var input;

  NxOperationMethod(this._method);

  String get inputType => _method.input;
  String get outputType => _method.output;
}

class NxOperationParamValue implements Comparable<NxOperationParamValue> {

  nuxeo.OperationParam _param;
  @observable var value;

  NxOperationParamValue(this._param) {
    value = (_param.values != null && _param.values.isNotEmpty) ? _param.values.first : null;
  }

  String get name => _param.name;

  String get dataType => _param.type;

  String get widget => (_param.widget == null) ? "text" : _param.widget;

  bool get required => _param.isRequired;

  bool get isValid => !required || (required && value != null);

  int compareTo(NxOperationParamValue other) => _param.order - other._param.order;
}

@CustomTag("nx-operation")
class NXOperation extends PolymerElement {

  @published String opid;
  nuxeo.Operation _op;

  @observable String name;
  @observable String label;
  @observable String description;
  final List<NxOperationParamValue> params = toObservable([]);

  @observable int selectedMethodIndex = -1;
  final List<NxOperationMethod> methods = toObservable([]);
  @observable NxOperationMethod method;

  final List errors = toObservable([]);

  bool get applyAuthorStyles => true;

  NXOperation.created() : super.created();

  void opidChanged() {

    // Clear the result area
    var results = shadowRoot.querySelector("#result");
    if (results != null) {
      results.children.clear();
    }

    // Clear the errors
    errors.clear();
    // Reset the selected method
    selectedMethodIndex = -1;

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
      selectedMethodIndex = 0;
    });
  }

  void selectedMethodIndexChanged() {
    var m = (selectedMethodIndex == -1) ? null: methods[selectedMethodIndex];
    method = notifyPropertyChange(#method, method, m);
  }

  void callOp(evt) {
    evt.preventDefault(); // don't submit the form

    var valid = shadowRoot.querySelectorAll("nx-widget").every((_) => _.input.validity.valid);

    if (!valid) {
      return;
    }

    // Clear previous results and errors
    var container = shadowRoot.querySelector("#result");
    container.children.clear();
    errors.clear();

    // Setup the parameters
    var opParams = {};
    params.forEach((param) {
      opParams[param.name] = param.value;
    });

    // Call the op
    NX.op(_op.id)(input: method.input, params: opParams)
    .then((res) {
      if ( (res is nuxeo.Document) || (res is Iterable)) {
        var docs = (res is nuxeo.Document) ? [res] : res;
        if (docs.isEmpty) {
          container.appendText("Empty");
        } else {
          docs.forEach((doc) {
            NXDocument docEl = new Element.tag("nx-document");
            docEl.document = doc;
            container.append(docEl);
          });
        }
      } else if (res is http.Blob) {
        var blob = new Blob([res.content], res.mimetype);
        var info = new Element.tag("div");
        info.text = res.mimetype + " (" + new FileSizeToString().forward(res.length) + ")";
        container.append(info);
        /* TODO(nfgs) - Read the Blob
        var reader = new FileReader()
        ..onLoadEnd.listen((e) {
          var url = e.target.result;
          var link = new Element.tag("a");
          link.href = url;
          link.text = "Download";
          link.target = "_blank";
          container.append(link);
          if (res.mimetype.startsWith("image")) {
            var img = new Element.tag("image");
            img.src = url;
            container.append(img);
          }
        })
        ..readAsDataUrl(blob);
        */
      } else {
        container.append(new Element.tag("div")..text = res.toString());
      }
    })
    .catchError((e) {
      var message = (e is nuxeo.ClientException)? e.message : e.toString();
      errors.add(message);
    });
  }

}