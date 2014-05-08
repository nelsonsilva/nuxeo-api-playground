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
    _doChangeTab(event.target.dataset["tab"]);
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
    });
  }

  responseChanged() {
    if (response == null) {
      body = null;
      currentTab = null; // Clear the polymer generated content
    } else if (response.headers["content-type"] == nuxeo.CTYPE_ENTITY ||
           response.headers["content-type"] == nuxeo.CTYPE_JSON) {
      var json = JSON.decode(response.body);

      body = new JsonEncoder.withIndent(" " * 2).convert(json);

      _doChangeTab("response");

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

  _doChangeTab([tab]) {
    currentTab = tab;
    shadowRoot.querySelectorAll(".ui.menu .item").forEach((Element e) {
      if (e.dataset["tab"] == tab) {
        e.classes.add("active");
      } else {
        e.classes.remove("active");
      }
    });
    async((_) { _highlight(); });
  }

}