import 'dart:html';
import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;

@observable
class NxOperationParamValue implements Comparable<NxOperationParamValue> {
  nuxeo.OperationParam param;
  var value;

  NxOperationParamValue(this.param) {
    value = (param.values != null && param.values.isNotEmpty) ? param.values.first : null;
  }

  String get name => param.name;

  String get dataType => param.type;

  String get widget => (param.widget == null) ? "text" : param.widget;

  bool get required => param.isRequired;

  int compareTo(NxOperationParamValue other) => param.order - other.param.order;
}

class NXOperation extends WebComponent {

  String _opId;
  nuxeo.Operation _op;

  @observable String name;
  @observable String description;
  @observable List<NxOperationParamValue> params = toObservable([]);

  @observable List result = toObservable([]);

  get opid => (_op == null) ? null : _op.id;
  set opid(String id) {
    result.clear();
    NX.registry.then((registry) {
      _op = registry[id];
      name = _op.id;
      description = _op.description;
      params.clear();
      params.addAll(_op.params.values.map((p) => new NxOperationParamValue(p)).toList());
      params.sort();
    });
  }

  inserted() {
    FormElement form = host.query('form');

    form.onSubmit.listen((Event e) {
      e.preventDefault();
      callOp();
    });
  }

  void callOp() {
    var opParams = {};
    params.forEach((param) {
      opParams[param.name] = param.value;
    });
    NX.op(_op.id)(params: opParams).then((List list) {
      result.clear();
      result.addAll(list);
    });
  }
}