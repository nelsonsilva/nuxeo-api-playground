library model;

import 'dart:collection';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;

nuxeo.Client NX = null;

final appModel = new Model._();

class Model extends ObservableBase {

  @observable
  bool isConnected = false;

  @observable
  List<NXOperationCategory> categories = toObservable(new LinkedHashSet());

  @observable
  List list = toObservable([]);

  @observable
  String selectedOp = null;

  @observable
  String username;

  @observable
  List<Alert> alerts = toObservable([]);

  Model._();
}

class NXOperationCategory extends ObservableBase {

  static var ID = 1;

  final id = ID++;

  @observable
  List<nuxeo.Operation> operations = toObservable([]);

  @observable String name;

  @observable String collapse = "collapse";

  toggle() {
    collapse = (collapse == "") ? "collapse" : "";
  }

  NXOperationCategory(this.name);

}

class Alert {
  String style;
  String title;
  String message;
  Alert.danger(this.title, this.message) : style = "danger";
}