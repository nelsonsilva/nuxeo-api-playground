library nx_widget;

import 'package:polymer/polymer.dart';

@CustomTag("nx-widget")
class NXWidget extends PolymerElement with ChangeNotifierMixin {

  static int COUNT = 0;

  String widgetId;

  String __$datatype;
  String get datatype => __$datatype;
  set datatype(String value) {
    __$datatype = notifyPropertyChange(const Symbol('datatype'), __$datatype, value);
  }
  

  dynamic __$value;
  dynamic get value => __$value;
  set value(dynamic value) {
    __$value = notifyPropertyChange(const Symbol('value'), __$value, value);
  }
  

  bool __$required;
  bool get required => __$required;
  set required(bool value) {
    __$required = notifyPropertyChange(const Symbol('required'), __$required, value);
  }
  

  bool __$isText = true;
  bool get isText => __$isText;
  set isText(bool value) {
    __$isText = notifyPropertyChange(const Symbol('isText'), __$isText, value);
  }
  

  String __$label;
  String get label => __$label;
  set label(String value) {
    __$label = notifyPropertyChange(const Symbol('label'), __$label, value);
  }
  

  bool get applyAuthorStyles => true;


  String get widgetTemplate {
    return "nx_text_widget";
  }

  created() {
    super.created();
    widgetId = (++COUNT).toString();
  }

  set type(String t) {
    isText = (t == "text");
  }


  getValueWorkaround(key) {
    if (key == const Symbol('datatype')) return this.datatype;
    if (key == const Symbol('value')) return this.value;
    if (key == const Symbol('required')) return this.required;
    if (key == const Symbol('isText')) return this.isText;
    if (key == const Symbol('label')) return this.label;
    if (key == const Symbol('applyAuthorStyles')) return this.applyAuthorStyles;
    if (key == const Symbol('widgetTemplate')) return this.widgetTemplate;
    return null;
  }
  
  setValueWorkaround(key, value) {
    if (key == const Symbol('datatype')) { this.datatype = value; return; }
    if (key == const Symbol('value')) { this.value = value; return; }
    if (key == const Symbol('required')) { this.required = value; return; }
    if (key == const Symbol('isText')) { this.isText = value; return; }
    if (key == const Symbol('label')) { this.label = value; return; }
    if (key == const Symbol('type')) { this.type = value; return; }
  }
  }
//# sourceMappingURL=nx_widget.dart.map