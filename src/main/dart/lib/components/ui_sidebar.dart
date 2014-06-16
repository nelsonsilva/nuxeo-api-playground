library ui_sidebar;

import 'package:polymer/polymer.dart';
import 'semantic.dart';

@CustomTag("ui-sidebar")
class UISidebar extends PolymerElement with SemanticUI {

  UISidebar.created() : super.created() {
  }

  attached() {
    sidebar('.ui.sidebar', ['show']);
  }

  toggleSidebar() {
    sidebar('.ui.sidebar', ['toggle']);
  }

  detached() {
    sidebar('.ui.sidebar', ['hide']);
  }

}