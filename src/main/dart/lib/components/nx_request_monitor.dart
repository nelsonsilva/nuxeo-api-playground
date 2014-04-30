library nx_request_monitor;

import 'dart:convert';
import 'dart:js' as js;
import 'dart:html';
import 'ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_automation/client.dart' as nuxeo;

@CustomTag("nx-request-monitor")
class NXRequestMonitor extends NXElement {

  @published nuxeo.BaseRequest request;
  @published var response;

  @observable var body;

  @observable String currentTab = "response";

  NXRequestMonitor.created() : super.created() {
  }

  changeTab(event) {
    shadowRoot.querySelectorAll(".ui.menu .item").forEach((Element e) {
      if (e == event.target) {
        e.classes.add("active");
      } else {
        e.classes.remove("active");
      }
    });
    currentTab = event.target.dataset["tab"];
    async((_) { _highlight(); });
  }

  @observable
  String get CURLRequest {
    var url = (request is nuxeo.OperationRequest) ? "${request.uri}/${request.id}" : request.uri.toString();
    var method = request.request.method;
    var str = new StringBuffer("curl -X $method '$url'");
    request.headers.forEach((k, v) {
      str.write(" -H '$k: $v'");
    });
    if (request.requestData != null) {
      str.write(" -d '${request.requestData}'");
    }
    return str.toString();
  }

  requestChanged() {
    async((_) {
      shadowRoot.querySelectorAll(".ui.menu .item").forEach((e) {
        e.onClick.listen(changeTab);
      });
      _highlight();
    });
  }

  responseChanged() {
    if (response.headers["content-type"] == nuxeo.CTYPE_ENTITY ||
           response.headers["content-type"] == nuxeo.CTYPE_JSON) {
      var json = JSON.decode(response.body);

      body = new JsonEncoder.withIndent(" " * 2).convert(json);

      currentTab = "response";

      async((_) { _highlight(); });

    } else {
      // TODO(nfgs) - Handle Blob
      // http.Blob(content: body, mimetype: response.headers["content-type"]);
    }

  }

  _highlight() {
    shadowRoot.querySelectorAll('code').forEach((el) {
      js.context['hljs'].callMethod('highlightBlock', [el]);
    });
  }
}