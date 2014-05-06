library semantic;

import 'dart:js' as js;
import 'dart:html';

/// Mixin which provides some helpers for SemanticUI
abstract class SemanticUI extends Object implements Element {

  accordion(selectorsOrEl, [arguments]) {
    jQuery(selectorsOrEl).callMethod('accordion', []);
  }

  dropdown(selectorsOrEl, [arguments]) {
    jQuery(selectorsOrEl).callMethod('dropdown', []);
  }

  popup(selectorsOrEl, {on, position, content, title, html}) {
    var settings = {};
    settings["on"] = on;
    settings["position"] = position;
    settings["content"] = content;
    settings["title"] = title;
    settings["html"] = html;
    jQuery(selectorsOrEl).callMethod('popup', _jsify([settings]));
  }

  sidebar(selectorsOrEl, [arguments]) {
    jQuery(selectorsOrEl).callMethod('sidebar', arguments);
  }

  modal(selectorsOrEl) {
    var jqEl = jQuery(".ui.modal");
    jqEl.callMethod('modal', [new js.JsObject.jsify({"detachable": false})]);
    jqEl.callMethod('modal', ['show']);
  }

  // Some helper methods
  jQuery(selectorsOrEl) {
    var el = (selectorsOrEl is String) ? shadowRoot.querySelector(selectorsOrEl) : selectorsOrEl;
    return js.context.callMethod(r'$', [el]);
  }

  onDomChange(selectors, handler()) {
    var observer = new MutationObserver((mutations, observer) { handler(); });
    observer.observe(shadowRoot.querySelector(selectors), childList: true);
  }

  _jsify(arguments) => arguments.map((a) => ((a is! Map) && (a is! Iterable))? a : new js.JsObject.jsify(a)).toList();

}