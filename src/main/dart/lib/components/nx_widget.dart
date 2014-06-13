library nx_widget;

import 'dart:async' show Future, Completer;
import 'dart:js' as js;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'ui_filters.dart';
import 'package:nuxeo_client/http.dart' as http;

@CustomTag("nx-widget")
class NXWidget extends PolymerElement {

  @published String datatype;

  @published String type;

  @published var value;

  @published bool required;

  @published String label = "";

  @published List options;

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
    _upload(input.files).then((files) {
      if (type == "blob") {
        value = files[0];
      } else { // bloblist
        if (value == null) {
          value = [];
        }
        value..clear()..addAll(files);
      }
    });
  }

  Future _upload(files) {
    var futures = [];
    files.forEach((file) {
      var completer = new Completer();
      new FileReader()
      ..onLoadEnd.listen((e) {
        completer.complete(new http.Blob(
            content: e.target.result,
            mimetype: file.type,
            filename: file.name));
      })
      ..onError.listen((e) => completer.completeError(e.target.error))
      ..readAsArrayBuffer(file);
      futures.add(completer.future);
    });
    return Future.wait(futures);
  }
}