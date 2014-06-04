library nx_xpath;

import 'dart:convert' show JSON;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'ui_filters.dart';
import 'ui_module.dart';
import '../doctypes.dart' as nuxeo;

@CustomTag("nx-xpath")
class NXXPath extends NXElement with SearchFilter {

  int keyboardSelect = -1;
  bool skipSearch = false;
  
  final List fields = toObservable([]);
  
  @observable String value;
  
  // SearchFilter
  @observable String searchTerm = '';
  @observable String searchFilter = '';
  
  NXXPath.created() : super.created() {
    minSearchTermLength = 1;
  }
  
  @override
  onConnect() {
    // Schemas
    NX.config.schemas().then((response) {
      fields.clear();
      JSON.decode(response.body).forEach((s) {
        var schema = new nuxeo.Schema.fromJSON(s);
        schema.fields.forEach((f) {
          fields.add("${schema.prefix}:${f.name}");
        });
      });
    });
  }
  
  void valueChanged() {
    searchTerm = value;
  }
  
  void select(event, detail, target) {
    skipSearch = true;
    value = target.dataset["field"];
    _reset();
  }

  keyup(KeyboardEvent e, var detail, Node target) {
    switch (new KeyEvent.wrap(e).keyCode) {
      case KeyCode.ESC:
        _clear();
        break;
      case KeyCode.UP:
        _moveUp();
        break;
      case KeyCode.DOWN:
        _moveDown();
        break;
      case KeyCode.ENTER:
        _select();
        break;
    }
  }

  _moveDown() {
    List<Element> lis = _items;
    if (keyboardSelect >= 0) lis[keyboardSelect].classes.remove('selecting');
    keyboardSelect = ++keyboardSelect == lis.length ? 0 : keyboardSelect;
    lis[keyboardSelect].classes.add('selecting');
  }

  _moveUp() {
    List<Element> lis = _items;
    if (keyboardSelect >= 0) lis[keyboardSelect].classes.remove('selecting');
    if (keyboardSelect == -1) keyboardSelect = lis.length;
    keyboardSelect = --keyboardSelect == -1 ? lis.length-1 : keyboardSelect;
    lis[keyboardSelect].classes.add('selecting');
  }

  _clear() {
    _reset();
    value = '';
  }

  _select() {
    value = _items[keyboardSelect].dataset["field"];
    _reset();
  }

  _reset() {
    keyboardSelect = -1;
  }
  
  List<Element> get _items => shadowRoot.querySelectorAll('.item');
}