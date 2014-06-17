library nx_request_monitor;

import 'dart:convert';
import 'dart:js' as js;
import 'dart:html';
import 'dart:typed_data';
import 'ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:nuxeo_client/client.dart' as nuxeo;

@CustomTag("nx-request-monitor")
class NXRequestMonitor extends NXElement {

  @published nuxeo.BaseRequest request;
  @published var response;

  @observable var body;
  @observable String contentType;
  @observable String downloadUrl;

  @observable String currentTab = "response";

  NXRequestMonitor.created() : super.created() {
  }

  changeTab(event) {
    _doChangeTab(event.target.dataset["tab"]);
  }

  @observable
  String get CURLRequest {
    var url;
    var data = request.requestData;
    if (request is nuxeo.OperationRequest) {
      url = (request.uploader == null) ? "${request.uri}/${request.id}" : "${request.uri}/batch/execute";
    } else {
      url = request.uri.toString();
    }
    var method = request.request.method;
    var str = new StringBuffer("curl -X $method '$url'");
    request.headers.forEach((k, v) {
      str.write(" -H '$k: $v'");
    });
    if (data != null) {
      str.write(" -d '$data'");
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
      contentType = null;
      currentTab = null; // Clear the polymer generated content
      return;
    }

    contentType = response.headers["content-type"];
    if (contentType == nuxeo.CTYPE_ENTITY || contentType == nuxeo.CTYPE_JSON) {
      var json = JSON.decode(response.body);
      body = new JsonEncoder.withIndent(" " * 2).convert(json);
    } else if (contentType == "text/plain") {
      body = response.body;
    } else { //  Handle Blob
      body = response.buffer;
    }

    if (body != null) {
      _doChangeTab("response");
    }
  }

  @ObserveProperty("body contentType")
  updateDownloadUrl() {
    if (body == null || contentType == null) {
      downloadUrl = null;
      return;
    }

    var blob = new Blob([body], contentType);
    downloadUrl = Url.createObjectUrlFromBlob(blob);
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