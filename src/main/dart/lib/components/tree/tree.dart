library nx_tree;

// TODO: import 'dart:mirrors';
import 'tree_node.dart';
import '../semantic.dart';
import '../ui_module.dart';
import 'package:polymer/polymer.dart';

@CustomTag("nx-tree")
class Tree extends NXElement with SemanticUI {

  @published String root;
  @published bool multipleSelection = false;
  /// The document field to use as key
  @published String key = "uid"; // uid or path

  List _selection = toObservable([]);

  @published set selected(v) {
    if (v is! Iterable) {
      v = [v];
    }
    _selection..clear()..addAll(v.where((i) => i != null));
  }

  @published get selected {
    if (multipleSelection) {
      return _selection;
    }
    return _selection.isNotEmpty ? _selection[0] : null;
  }

  Tree.created() : super.created() {
  }

  bool get valid => true;

  bool get alwaysPrepare => true;

  enteredView() {
    super.enteredView();
    accordion(".ui.accordion");
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
    (shadowRoot.querySelector("nx-tree-node") as TreeNode).expand();
  }

  nodeSelected(event, detail, target) {

    var oldValue = selected;

    // Get the document key
    var doc = detail;
    var docId = (key == "uid") ? doc.uid : doc.path;

    // New selection
    if (!_selection.contains(docId)) {
      // Clear others if not multiple
      if (!multipleSelection) {
        _clearSelections(shadowRoot);
      }
      _selection.add(docId);
    } else { // Remove existing selection
      _selection.remove(docId);
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
