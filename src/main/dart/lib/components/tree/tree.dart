library nx_tree;

import 'dart:html';
import '../ui_module.dart';
import 'tree_node.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;

@CustomTag("nx-tree")
class Tree extends NXElement {

  @published String root;
  @published bool multipleSelection = false;

  List _selection = toObservable([]);

  @published set selected(v) {
    if (v is! Iterable) {
      v = [v];
    }
    _selection.addAll(v.where((i) => i != null));
  }

  @published get selected {
    if (multipleSelection) {
      return _selection;
    }
    return _selection.isNotEmpty ? _selection[0] : null;
  }

  Tree.created() : super.created() {
  }

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  bool get valid => true;

  enteredView() {
      jQuery(".ui.accordion").callMethod('accordion', []);
  }


  @override
  onConnect() {
    _expandRoot();
  }

  rootChanged() {
    if (isConnected) {
      _expandRoot();
    }
  }

  _expandRoot() {
    shadowRoot.querySelector("nx-tree-node").expand();
  }

  nodeSelected(event, detail, target) {

    var oldValue = selected;
    var docId = detail;

    if (!multipleSelection) {
      _clearSelections(shadowRoot);
    }

    if (_selection.contains(docId)) { // Remove existing selection
      _selection.remove(docId);
    } else { // Add new selection
      _selection.add(docId);
    }
    notifyPropertyChange(#selected, oldValue, selected);
  }

  _clearSelections(domRoot) {
    domRoot.querySelectorAll("nx-tree-node").forEach((n) {
      if (_selection.contains(n.docId)) {
        n.selected = false;
        _selection.remove(n.docId);
      }
      _clearSelections(n.shadowRoot);
    });
  }
}
