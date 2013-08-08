import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:nuxeo_automation/automation.dart' as nuxeo;

class NXWidget extends WebComponent {

  static int COUNT = 0;

  int _widgetCount;
  String label;
  String type;
  String datatype;

  @observable
  dynamic value;

  bool required;

  get widgetId => "nx_widget_${_widgetCount}_$label";

  String get widgetTemplate {
    return "nx_text_widget";
  }

  inserted() {
    _widgetCount = ++COUNT;
  }
}