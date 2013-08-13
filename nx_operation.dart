library nx_operation;

import 'model.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;


class NxOperationParamValue extends ChangeNotifierBase implements Comparable<NxOperationParamValue> {

  nuxeo.OperationParam __$param;
  nuxeo.OperationParam get param => __$param;
  set param(nuxeo.OperationParam value) {
    __$param = notifyPropertyChange(const Symbol('param'), __$param, value);
  }
  
  dynamic __$value;
  dynamic get value => __$value;
  set value(dynamic value) {
    __$value = notifyPropertyChange(const Symbol('value'), __$value, value);
  }
  

  NxOperationParamValue(param) : __$param = param {
    value = (param.values != null && param.values.isNotEmpty) ? param.values.first : null;
  }

  String get name => param.name;

  String get dataType => param.type;

  String get widget => (param.widget == null) ? "text" : param.widget;

  bool get required => param.isRequired;

  int compareTo(NxOperationParamValue other) => param.order - other.param.order;

  getValueWorkaround(key) {
    if (key == const Symbol('param')) return this.param;
    if (key == const Symbol('value')) return this.value;
    if (key == const Symbol('name')) return this.name;
    if (key == const Symbol('dataType')) return this.dataType;
    if (key == const Symbol('widget')) return this.widget;
    if (key == const Symbol('required')) return this.required;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('param')) { this.param = value; return; }
    if (key == const Symbol('value')) { this.value = value; return; }
  }
  }

@CustomTag("nx-operation")
class NXOperation extends PolymerElement with ChangeNotifierMixin {

  String _opId;
  nuxeo.Operation _op;

  String __$name;
  String get name => __$name;
  set name(String value) {
    __$name = notifyPropertyChange(const Symbol('name'), __$name, value);
  }
  
  String __$label;
  String get label => __$label;
  set label(String value) {
    __$label = notifyPropertyChange(const Symbol('label'), __$label, value);
  }
  
  String __$description;
  String get description => __$description;
  set description(String value) {
    __$description = notifyPropertyChange(const Symbol('description'), __$description, value);
  }
  
  List<NxOperationParamValue> __$params = toObservable([]);
  List<NxOperationParamValue> get params => __$params;
  set params(List<NxOperationParamValue> value) {
    __$params = notifyPropertyChange(const Symbol('params'), __$params, value);
  }
  

  List __$result = toObservable([]);
  List get result => __$result;
  set result(List value) {
    __$result = notifyPropertyChange(const Symbol('result'), __$result, value);
  }
  

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

  getValueWorkaround(key) {
    if (key == const Symbol('name')) return this.name;
    if (key == const Symbol('label')) return this.label;
    if (key == const Symbol('description')) return this.description;
    if (key == const Symbol('params')) return this.params;
    if (key == const Symbol('result')) return this.result;
    if (key == const Symbol('applyAuthorStyles')) return this.applyAuthorStyles;
    if (key == const Symbol('opid')) return this.opid;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('name')) { this.name = value; return; }
    if (key == const Symbol('label')) { this.label = value; return; }
    if (key == const Symbol('description')) { this.description = value; return; }
    if (key == const Symbol('params')) { this.params = value; return; }
    if (key == const Symbol('result')) { this.result = value; return; }
    if (key == const Symbol('opid')) { this.opid = value; return; }
  }
  }
//# sourceMappingURL=nx_operation.dart.map