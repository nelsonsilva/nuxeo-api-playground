library nx_widget;

import 'package:polymer/polymer.dart';

@CustomTag("nx-widget")
class NXWidget extends PolymerElement with ObservableMixin {

  static int COUNT = 0;

  String widgetId;

  @observable String datatype;

  @observable dynamic value;

  @observable bool required;

  @observable bool isText = true;

  @observable String label;

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

}