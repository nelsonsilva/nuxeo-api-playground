library nx_widget;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'ui_filters.dart';
import 'package:nuxeo_automation/http.dart' as http;

@CustomTag("nx-widget")
class NXWidget extends PolymerElement {

  @observable String datatype;

  @observable String type;

  @observable var value;

  @observable bool required;

  @observable String label = "";

  bool get applyAuthorStyles => true;

  String get widgetTemplate {
    return "nx_text_widget";
  }

  NXWidget.created() : super.created();

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

  // TODO(nfgs) - Try to get this working in the template
  @observable int cols = 12;
  labelChanged() { cols = (label.isEmpty) ? 12 : 8; }
}