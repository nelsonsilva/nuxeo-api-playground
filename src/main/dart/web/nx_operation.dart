library nx_operation;

import 'model.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;


class NxOperationParamValue extends ObservableBase implements Comparable<NxOperationParamValue> {

  @observable nuxeo.OperationParam param;
  @observable var value;

  NxOperationParamValue(this.param) {
    value = (param.values != null && param.values.isNotEmpty) ? param.values.first : null;
  }

  String get name => param.name;

  String get dataType => param.type;

  String get widget => (param.widget == null) ? "text" : param.widget;

  bool get required => param.isRequired;

  int compareTo(NxOperationParamValue other) => param.order - other.param.order;
}

@CustomTag("nx-operation")
class NXOperation extends PolymerElement with ObservableMixin {

  String _opId;
  nuxeo.Operation _op;

  @observable String name;
  @observable String label;
  @observable String description;
  @observable List<NxOperationParamValue> params = toObservable([]);

  @observable List result = toObservable([]);

  bool get applyAuthorStyles => true;

  get opid => (_op == null) ? null : _op.id;
  set opid(String id) {
    result.clear();
    NX.registry.then((registry) {
      _op = registry[id];
      name = _op.id;
      label = _op.label;
      description = _op.description;
      params.clear();
      params.addAll(_op.params.values.map((p) => new NxOperationParamValue(p)).toList());
      params.sort();
    });
  }

  void callOp(evt) {
    evt.preventDefault();
    var opParams = {};
    params.forEach((param) {
      opParams[param.name] = param.value;
    });
    NX.op(_op.id)(params: opParams).then((res) {
      result.clear();
      if (res is nuxeo.Document) {
        result.add(res);
      } else if (res is nuxeo.PaginableDocuments) {
        result.addAll(res);
      }
    });
  }
}