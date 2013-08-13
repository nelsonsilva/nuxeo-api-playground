library model;

import 'dart:collection';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;
import 'package:observe/observe.dart' as __observe;


nuxeo.Client NX = null;

final appModel = new Model._();

class Model extends ChangeNotifierBase {

  bool __$isConnected = false;
  bool get isConnected => __$isConnected;
  set isConnected(bool value) {
    __$isConnected = notifyPropertyChange(const Symbol('isConnected'), __$isConnected, value);
  }
  

  List<NXOperationCategory> __$categories = toObservable(new LinkedHashSet());
  List<NXOperationCategory> get categories => __$categories;
  set categories(List<NXOperationCategory> value) {
    __$categories = notifyPropertyChange(const Symbol('categories'), __$categories, value);
  }
  

  List __$list = toObservable([]);
  List get list => __$list;
  set list(List value) {
    __$list = notifyPropertyChange(const Symbol('list'), __$list, value);
  }
  

  String __$selectedOp = null;
  String get selectedOp => __$selectedOp;
  set selectedOp(String value) {
    __$selectedOp = notifyPropertyChange(const Symbol('selectedOp'), __$selectedOp, value);
  }
  

  String __$username;
  String get username => __$username;
  set username(String value) {
    __$username = notifyPropertyChange(const Symbol('username'), __$username, value);
  }
  

  List<Alert> __$alerts = toObservable([]);
  List<Alert> get alerts => __$alerts;
  set alerts(List<Alert> value) {
    __$alerts = notifyPropertyChange(const Symbol('alerts'), __$alerts, value);
  }
  

  Model._();

  getValueWorkaround(key) {
    if (key == const Symbol('isConnected')) return this.isConnected;
    if (key == const Symbol('categories')) return this.categories;
    if (key == const Symbol('list')) return this.list;
    if (key == const Symbol('selectedOp')) return this.selectedOp;
    if (key == const Symbol('username')) return this.username;
    if (key == const Symbol('alerts')) return this.alerts;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('isConnected')) { this.isConnected = value; return; }
    if (key == const Symbol('categories')) { this.categories = value; return; }
    if (key == const Symbol('list')) { this.list = value; return; }
    if (key == const Symbol('selectedOp')) { this.selectedOp = value; return; }
    if (key == const Symbol('username')) { this.username = value; return; }
    if (key == const Symbol('alerts')) { this.alerts = value; return; }
  }
  }

class NXOperationCategory extends ChangeNotifierBase {

  static var ID = 1;

  final id = ID++;

  List<nuxeo.Operation> __$operations = toObservable([]);
  List<nuxeo.Operation> get operations => __$operations;
  set operations(List<nuxeo.Operation> value) {
    __$operations = notifyPropertyChange(const Symbol('operations'), __$operations, value);
  }
  

  String __$name;
  String get name => __$name;
  set name(String value) {
    __$name = notifyPropertyChange(const Symbol('name'), __$name, value);
  }
  

  String __$collapse = "collapse";
  String get collapse => __$collapse;
  set collapse(String value) {
    __$collapse = notifyPropertyChange(const Symbol('collapse'), __$collapse, value);
  }
  

  toggle() {
    collapse = (collapse == "") ? "collapse" : "";
  }

  NXOperationCategory(name) : __$name = name;


  getValueWorkaround(key) {
    if (key == const Symbol('operations')) return this.operations;
    if (key == const Symbol('name')) return this.name;
    if (key == const Symbol('collapse')) return this.collapse;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('operations')) { this.operations = value; return; }
    if (key == const Symbol('name')) { this.name = value; return; }
    if (key == const Symbol('collapse')) { this.collapse = value; return; }
  }
  }

class Alert {
  String style;
  String title;
  String message;
  Alert.danger(this.title, this.message) : style = "danger";
}
//# sourceMappingURL=model.dart.map