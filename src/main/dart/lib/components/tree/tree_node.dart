library nx_tree_node;

import 'dart:html';
import '../ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;

const GET_CHILDREN = "Document.GetChildren";
const FETCH_DOCUMENT = "Document.Fetch";

const DEFAULT_ICON = "icons/folder.gif";
const DOCTYPE_ICONS = const {
  "File": "icons/file.gif",
  "Folder": "icons/folder.gif",
  "Domain": "icons/domain.gif",
  "Workspace": "icons/workspace.gif",
  "Note": "icons/note.gif"
};

@CustomTag("nx-tree-node")
class TreeNode extends NXElement {

  static const String SELECTED_EVENT = "nodeselected";

  @published String docId;
  @published nuxeo.Document doc;
  @published List children = toObservable([]);
  @published bool selected = false;

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  TreeNode.created() : super.created() {
  }

  enteredView() {
    jQuery(".ui.accordion").callMethod('accordion', []);
  }

  @published bool multiple = false;

  @observable get icon {
    if (doc == null) {
      return DEFAULT_ICON;
    }
    var icon = DOCTYPE_ICONS[doc.type];
    if (icon == null) {
      icon = DEFAULT_ICON;
    }
    return icon;
  }

  @observable get isFolderish => true; //(doc != null) && doc.facets.contains("Folderish");

  @override
  onConnect() {
    if (docId != null) {
      _fetchDoc();
    }
  }

  docIdChanged() {
    if (isConnected) {
      _fetchDoc();
    }
  }

  docChanged(oldValue, newValue) {
    notifyPropertyChange(#icon, null, this.icon);
    notifyPropertyChange(#isFolderish, null, this.isFolderish);
  }

  void expand() {
    if (children.isNotEmpty) {
      return;
    }
    print("fetching and expanding ${docId}");
    NX.doc(docId).children().fetch().then((docs) {
      children..clear()..addAll(docs);
    });
  }

  void toggle(event, detail, target) {
    if (target.classes.contains("active")) {
      return;
    }
    expand();
  }


  void toggleSelection(MouseEvent event, detail, target) {
    event.preventDefault();
    event.stopImmediatePropagation();
    selected = !selected;
    dispatchEvent(new CustomEvent(SELECTED_EVENT, detail: doc.uid));
  }

  _fetchDoc() {
    NX.doc(docId).fetch().then((doc) {
      this.doc = doc;
    });
  }

}