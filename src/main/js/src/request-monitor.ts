/**
@license
(C) Copyright Nuxeo Corp. (http://nuxeo.com/)
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import { LitElement, html, property } from '@polymer/lit-element';
import { classMap } from 'lit-html/directives/classMap.js';
import { customElement } from './decorators';

import {
  IconCSS,
  LabelCSS,
  SegmentCSS,
  BreadcrumbCSS,
  MenuCSS,
  LoaderCSS,
  DimmerCSS,
  TabCSS,
  ListCSS
} from './semantic';

import { StyleCSS } from './shared-styles';
import { highlight, HighlightCSS } from './highlight';

const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_JSON = "application/json";
const CTYPE_TEXT = "text/plain";

@customElement('nuxeo-request-monitor')
export class RequestMonitor extends LitElement {


  @property() body: any;
  @property() headers: any;

  @property() private _request: Request;
  @property() private _response: Response;

  /// A list of Blobs for downloading the response.
  downloads = [];

  @property() currentTab: string = "response";

  render() {

    return html`
    <style>
      ${IconCSS}
      ${LabelCSS}
      ${SegmentCSS}
      ${BreadcrumbCSS}
      ${MenuCSS}
      ${LoaderCSS}
      ${DimmerCSS}
      ${TabCSS}
      ${ListCSS}
      ${HighlightCSS}
      ${StyleCSS}
    </style>

    <div class="ui top attached tabular menu">
      <a class="${classMap({item: true, active: this.currentTab == 'response'})}" @click="${_ => this.currentTab = 'response'}">Response</a>
      <a class="${classMap({item: true, active: this.currentTab == 'headers'})}" @click="${_ => this.currentTab = 'headers'}">Headers</a>
      <a class="${classMap({item: true, active: this.currentTab == 'curl'})}" @click="${_ => this.currentTab = 'curl'}">CURL request</a>
    </div>
    <div class="ui bottom attached segment">${this.renderTab()}</div>
    `;
  }

  get contentType() {
    return this.response && this.response.headers.get('content-type');
  }

  set response(response: Response) {
    if (!response) {
      return;
    }

    this._response = response.clone();

    this._readBody().then(() => {
      this.currentTab = "response";
      // this.shadowRoot.querySelectorAll('code').forEach(highlight)
    });
  }

  async _readBody() {
    const { contentType, response } = this;

    if (contentType != null && (contentType.startsWith(CTYPE_ENTITY) || contentType.startsWith(CTYPE_JSON))) {
      let json = await response.json();
      this.body = JSON.stringify(json, null, '  ');
    } else if (contentType != null && contentType.startsWith(CTYPE_TEXT)) {
      this.body = await response.text();
    } else { //  Handle Blob
      this.body = await response.blob();
    }
  }
  
  get response(): Response {
    return this._response;
  }

  async renderTab() {
    let { request, response, contentType, body, currentTab } = this;

    const responseHeaders = {};
    response.headers.forEach((v, k) => responseHeaders[k] = v);

    // compute fetch options
    let opts = request._computeOptions();
    opts = Nuxeo.prototype._computeFetchOptions(opts)
    const requestHeaders = opts.headers;

    switch (currentTab) {
      case 'response':
        return html`
        <!-- Status code and text -->
        ${response.status != 0 ? html`
            <div class="ui top right attached label"><div class="detail">${response.status}</div> ${response.statusText}</div>
        `: ''}
        <!-- Content Type 
        <div class="ui small list">
        <template repeat="{{blob in downloads | enumerate}}">
            <template if="{{blob.index == 0}}">
                <div class="ui ribbon label">
                    {{blob.value.mimetype}}&nbsp;<a target="_blank" _href="{{blob.value | asBlobUrl}}" title="Download"><i class="download disk icon"></i></a>
                </div>
            </template>
            <template if="{{blob.index > 0}}">
                <div class="item">
                    <i class="download disk icon"></i>
                    <div class="content">
                    <a class="header" target="_blank" _href="{{blob.value | asBlobUrl}}" title="Download {{blob.value.filename}}">{{blob.value.filename}}</a>
                    </div>
                </div>
            </template>
        </template>
        </div>
        -->

        <!-- Body -->
        <div class="ui basic segment">
          <div id="loading" class="ui dimmer">
            <div class="ui large text loader">Loading</div>
          </div>
          ${(contentType.startsWith(CTYPE_JSON) || contentType == CTYPE_TEXT) ? html`<pre><code id="code">${body}</code></pre>`: ''}
        </div>
        `;
        
    case 'headers':
    
        
        return html`
        <div class="ui ribbon label">Request Headers</div>
          <code class="json">
            ${Object.entries(requestHeaders).map(([k, v]) => html`<p>"${k}": "${v}"</p>`)}
          </code>
        </div>

        <div class="ui ribbon label">Response Headers</div>
          <code class="json">
            ${Object.entries(responseHeaders).map(([k, v]) => html`<p>"${k}": "${v}"</p>`)}
          </code>
        </div>
        `;
    case 'curl':
        let url = request.url;
        //var data = request.requestData;
        /*
        if (request is nuxeo.OperationRequest) {
            url = (!(request as nuxeo.OperationRequest).hasBatchUpload) ? "${request.uri}/${request.id}" : "${request.uri}/batch/execute";
        } else {
            url = request.uri.toString();
        }
        */
        var method = request.method;
        let str = `curl -X ${method} '${url}'"`;
        Object.entries(requestHeaders).forEach(([k, v]) => str += ` -H '${k}: ${v}'`);
        /*
        if (data != null) {
        if (data is http.MultipartFormData) {
            data.data.forEach((k, blob) {
            // If key is "request" we know this is JSON so we can display it
            // Everything else is considered a file
            var value = (k == "request") ? new String.fromCharCodes(blob.content) : "@${blob.filename}";
            str.write(" -F $k='$value;type=${blob.mimetype}'");
            });
        } else {
            str.write(" -d '$data'");
        */
        return html`<code>${str}</code>`;
    }
  }

  onConnected() {
    //this.requestChanged();
  }

  set request(request: Request) {
    this._request = request;
    if (request) {
      // this.request.onrequest.listen((_) => { this.isLoading = true; });
      // this.request.onresponse.listen((_) => { this.isLoading = false; });
    }
  }

  get request(): Request {
    return this._request;
  }

  set isLoading(flag: boolean) {
    var classes = this.shadowRoot.getElementById("loading").classList;
    flag ? classes.add("active") : classes.remove("active");
  }

  updated(changed){
    if (changed.has('response')) {
      this.shadowRoot.querySelectorAll('code').forEach(highlight)
    }
  }

  /*@ObserveProperty("body contentType")
  updateDownloads() {
    downloads.clear();

    if (body == null || contentType == null) {
      return;
    }

    // Allow downloading the response as a blob
    downloads.add(new http.Blob(
        content: body,
        mimetype: (contentType.startsWith("multipart/mixed") ? "multipart/mixed" : contentType)));

    // For multipart also allow downloading each part as a blob
    if (multipart.isMultipartContent(contentType)) {
      var boundary = multipart.getMultipartBoundary(contentType);
      // We only support parsing multipart responsed when the boundary is known beforehand
      if (boundary != null) {
        multipart.parse(new Uint8List.view(response.buffer), boundary).then((blobs) {
          downloads.addAll(blobs);
        });
      }
    }
  }*/

}
