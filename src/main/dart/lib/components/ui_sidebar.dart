library ui_sidebar;

import 'package:polymer/polymer.dart';
import 'semantic.dart';

@CustomTag("ui-sidebar")
class UISidebar extends PolymerElement with SemanticUI {

  UISidebar.created() : super.created() {
  }

  enteredView() {
    sidebar('.ui.sidebar', ['show']);
  }

  toggleSidebar() {
    sidebar('.ui.sidebar', ['toggle']);
  }

  leftView() {
    sidebar('.ui.sidebar', ['hide']);
  }

}