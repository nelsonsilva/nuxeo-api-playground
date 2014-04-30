library nx_widget;

import 'dart:js' as js;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'ui_filters.dart';
import 'package:nuxeo_automation/http.dart' as http;

@CustomTag("nx-widget")
class NXWidget extends PolymerElement {

  @published String datatype;

  @published String type;

  @published var value;

  @published bool required;

  @published String label = "";

  String get widgetTemplate {
    return "nx_text_widget";
  }

  NXWidget.created() : super.created();

  showModal() {
    var el = shadowRoot.querySelector(".ui.modal");
    var jqEl = js.context.callMethod(r'$', [el]);
    jqEl.callMethod('modal', [new js.JsObject.jsify({"detachable": false})]);
    jqEl.callMethod('modal', ['show']);
  }

  get valid => input.validity.valid;
  get input => shadowRoot.querySelector("#widget");

  /// File handling

  get asFileSize => new FileSizeToString();

  onFileSelected() {
    File file = input.files[0];
    if (file == null) return;
    new FileReader()
    ..onLoadEnd.listen((e) {
      value = new http.Blob(
          content: e.target.result,
          mimetype: file.type,
          filename: file.name);
    })
    ..onError.listen((e) => throw new Exception(e.target.error))
    ..readAsArrayBuffer(file);
  }

}