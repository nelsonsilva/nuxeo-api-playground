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

import { html, property } from '@polymer/lit-element';
import { when } from 'lit-html/directives/when';
import { ModuleElement } from './module-element';
import { accordion, sidebar, modal } from './semantic';
import { customElement } from './decorators';
import './tree'
import './widget';

import {
  ButtonCSS,
  HeaderCSS,
  IconCSS,
  ImageCSS,
  SegmentCSS,
  BreadcrumbCSS,
  MenuCSS,
  MessageCSS,
  TableCSS,
  AccordionCSS,
  TabCSS,
  DimmerCSS,
  SidebarCSS,
  ModalCSS,
  TransitionCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

const DEFAULT_DOCUMENT_BODY = `
{
  "entity-type": "document",
  "name":"newDoc",
  "type": "File",
  "properties": {
      "dc:title": "A new document",
      "dc:description": "Created via the REST API"
  }
}`;

const CTYPE_ENTITY = "application/json+nxentity";
const CTYPE_JSON = "application/json";

@customElement('nuxeo-repository-browser')
export class RepositoryBrowser extends ModuleElement {

  @property() _op?: string;
  @property() errors: string[];
  @property() request: Request;
  @property() response: any;
  @property() document: any;

  constructor() {
    super('browser');
    this.title = "Repository";
    this.icon = "repository.png";
    this.description = "Browse the repository you are connected to and discover the content that is inside.";
    this.action = "Explore";
    this.errors = [];
  }

  render() {
    const { title, icon, description, documentId, document, adapter, method, request, response, errors } = this;

    let breadcrumb;
    let thumbnail;

    if (document != null) {
      breadcrumb = [{"title" : document.title}];
      thumbnail = (document && document.facets.contains("Folderish")) ? "icons/folder_100.png" : "icons/file_100.png";

      if (document.contextParameters != null) {
        if (document.contextParameters.containsKey("breadcrumb")) {
          breadcrumb = document.contextParameters["breadcrumb"]["entries"];
        }
        if (document.contextParameters.containsKey("thumbnail")) {
          thumbnail = document.contextParameters["thumbnail"]["url"];
          // TODO  
          // if (connection.token != null) {
          //  thumbnail += "?token=${connection.token}";
          // }
        }
      }
    }

    return html`
  
    <style>
      ${ButtonCSS}
      ${HeaderCSS}
      ${IconCSS}
      ${ImageCSS}
      ${SegmentCSS}
      ${BreadcrumbCSS}
      ${MenuCSS}
      ${MessageCSS}
      ${TableCSS}
      ${AccordionCSS}
      ${TabCSS}
      ${DimmerCSS}
      ${ModalCSS}
      ${TransitionCSS}
      ${SidebarCSS}
      ${StyleCSS}
    </style>
    
    <!-- Sidebar -->
    <div class="ui vertical sidebar">
      <div class="ui fluid vertical menu">
        <!-- Navigation -->
        <a class="ui red inverted header item" href="/">
          <i class="circle left icon"></i>
          ${title}
        </a>
        <div class="item">
          <!-- Endpoints -->
          <nuxeo-tree id="tree" rootpath="/" selected="${documentId}"></nuxeo-tree>
        </div>
      </div>
    </div>
    <!-- Button -->
    <div class="ui blue launch right attached button" id="leftmenu" @click="${() => sidebar(this.sidebar, 'toggle')}">
        <i class="reorder icon"></i>
    </div>

    <div class="ui full page grid">
      <div class="column">

        <!--  Breadcrumb -->
        <div class="ui segment brdcrmb">
          <div class="ui breadcrumb">
            <a class="section" href="/"><i class="ui home icon"></i></a>
            <div class="divider"> / </div>
             <span class="active section">${title}</span>
             ${breadcrumb && breadcrumb.map((entry)=> html`
                <div class="divider"> / </div>
                <div class="active section">${entry.title}</div>
                `)
             }
          </div>
       </div>

        ${when(!document,
          () => html`
          <div class="ui raised segment">
            <h3 class="ui blue header">${title}</h3>
            <div class="ui grid">
              <div class="four wide column"><img class="ui medium image" src="../images/${icon}"></div>
              <div class="twelve wide column">
                <p class="description">${description}</p>
              </div>
            </div>
          </div>`,
          () => html`
          <div class="ui vertical segment">
            <div class="ui basic segment">
              <img class="ui small circular image" style="display:inline-block;background-color:white" src="${thumbnail}">
              <span class="ui middle aligned huge header">${document.title}</span>
            </div>
            <div class="ui basic segment">
              ${method} /api/v1/id/${documentId}${adapter ? `/@${adapter.name}`: ''}
              <div class="ui blue submit button" style="float:right" @click="${() => this.runRequest()}">Execute</div>
            </div>
         </div>`)}
      </div>
    </div>

    ${document ? html`
      <div class="ui two column stackable full page grid">
        <div class="column">
          <div id="methods" class="ui top attached tabular menu">
            <a class="item active" data-method="GET">GET</a>
            <a class="item" data-method="PUT">PUT</a>
            <a class="item" data-method="POST">POST</a>
            <a class="item" data-method="DELETE">DELETE</a>
          </div>
          <div class="ui bottom attached segment">
            ${this.requestOptions()}

            <!-- Submit button -->
            <div class="ui basic right aligned segment">
              <div class="ui blue submit button" @click="${() => this.runRequest()}">Execute</div>
            </div>
          </div>

          ${errors.length ? html`
            <div class="ui bottom attached error message">
              ${errors.map((error) => html`<p><i class="icon warning"></i>${error}</p>`)}
            </div>
            `: ''}
          <br/>

        </div>

        <div class="column">
          <nuxeo-request-monitor request="${request}" response="${response}"></nuxeo-request-monitor>
        </div>
      </div>
    ` : ''}
    `;
  }

  update(changedProps) {
    super.update(changedProps);
    if (changedProps.has('_op')) {
      this.operationChanged(this._op);
    }
  }

  get sidebar() { return this.shadowRoot.querySelector('.ui.sidebar'); }

  firstUpdated() {
    sidebar(this.sidebar, 'show');
  }

  updated() {
    accordion(this.shadowRoot.getElementById('endpoints'))

    // activate the accordions
    accordion(this.shadowRoot.getElementById('adapters'));
    accordion(this.shadowRoot.getElementById('enrichers'));
    accordion(this.shadowRoot.getElementById('options'));

    // activate the tabs
    this.shadowRoot.querySelectorAll("#methods .item").forEach((e) => {
      e.onclick = ((event) => {
        this.method = event.target.dataset["method"];
      });
    });

    modal(this.shadowRoot.querySelectorAll('.ui.modal'));
  }

  route(endpoint, idx, method) {
    if (!endpoint || !idx || !method) {
      this.operation = this.endpoint = undefined;
      return;
    }

    this.endpoint = this.endpoints[endpoint][parseInt(idx)];
    this.operation = this.endpoint && this.endpoint.operations.find((o) => o.method == method);
  }

  documentIdChanged() {
    this.method = 'GET';
    this.body = null;

    if (this.documentId == null) {
      document = null;
    } else {
      this.request = this.client.request(`/id/${this.documentId}`);
      this.request.enrichers("breadcrumb,thumbnail");

      this.runRequest();
    }
  }

  adapterChanged() {
    this.request._path = `id/${this.documentId}`; // reset the request uri
    if (this.adapter != null) {
      this.request._path += `/@${this.adapter}`;
    }
  }

  runRequest() {
    this.errors = [];
    if (this.adapter != null) {
      this.adapter.params
      .filter((p) => p.isQueryParam && !p.isEmpty)
      .forEach((param) => {
        this.request._queryParams[param.name] = param.value;
      });
    }
    var data = (this.method == 'PUT' || this.method == 'POST') ? this.body : null;
    return this.request.execute({method: this.method, body: data})
      .then(this._handleResponse)
      .catch((e) => {

          // Store the response
          this.response = e.response;
          this.errors.push(e.message);
      });
  }

  _handleResponse(response) {
    this.response = response;

    // if current document was deleted remove the node from the tree
    if (this.method == 'DELETE') {
      this.shadowRoot.querySelector("#tree").deleteNode(this.documentId);
    }

    // process the response
    let contentType = response.headers["content-type"];
    if (contentType != null && (contentType.startsWith(CTYPE_ENTITY) || contentType.startsWith(CTYPE_JSON))) {
      var json = JSON.parse(response.body);

      // if it's the current document update it
      if (json["entity-type"] == "document") {
        var document = JSON.parse(json);
        if (document.uid == this.documentId) {
          this.document = document;
        }
      }
    }

    return response;
  }

  documentChanged() {
    this._updateBreadcrumb();
    this._updateThumbnail();
  }

  setDefaultBody() {
    this.body = DEFAULT_DOCUMENT_BODY;
  }

  copyBody() {
    var json = JSON.parse(this.response.body);
    this.body = JSON.stringify(json);
  }

  referenceBatch(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
  }

  methodChanged() {
    this.errors = [];
    this.adapter = null;

    this.shadowRoot.querySelectorAll("#methods .item").forEach((e) => {
      if (e.dataset["method"] == this.method) {
        e.classes.add("active");
      } else {
        e.classes.remove("active");
      }
    });
  }

  requestOptions() {
    const { request, method, body, adapter, batch } = this;
    switch (method) {

      case 'GET':
        return html`
      <div class="ui basic segment">
        <nuxeo-web-adapters id="adapters" adapter="${adapter}"></nuxeo-web-adapters>
      </div>

      <div class="ui basic segment">
        <div id="enrichers" class="ui fluid accordion">
          <div class="title active">
            X-NXenrichers.document
            <a target="_blank" style="text-decoration:none; float:right" href="http://doc.nuxeo.com/nxdoc/content-enrichers">
              <i class="help icon"></i>
            </a>
          </div>
          <div class="content active">
            <nuxeo-content-enrichers request="${request}"></nuxeo-content-enrichers>
          </div>
        </div>
      </div>

      <div class="ui basic segment">
        <div id="options" class="ui fluid accordion">
          <div class="title">
            Advanced options
          </div>
          <div class="content">
            <nuxeo-request-options request="${request}"></nuxeo-request-options>
          </div>
        </div>
      </div>
    `;

    case 'POST':
    case 'PUT':

      return html`

      <div class="ui basic segment">
        <textarea required="true" value="${body}"></textarea>
      </div>

      <div class="ui basic horizontal right aligned segment">
        <!-- Copy default body -->
        ${ method == 'PUT' ? html`<div class="ui button" @click="${this.copyBody}">Copy document</div>` : ''}
        ${ method == 'POST' ? html`<div class="ui button" @click="${this.setDefaultBody}">Sample document</div>` : ''}
        <div class="ui button" @click="${this.referenceBatch}">Reference a Batch</div>
      </div>

      <div class="ui modal" style="width: auto;">
        <i class="close icon"></i>
        <div class="header">
          Select a batch.
        </div>
        <div class="content">
          ${ batch ? html`
            <div class="field">Copy past the JSON string below and report it on the document object you want to create<br/> or update, for the file property for which you want to upload a file, ex:<br/>
                <pre>{"entity-type":"document","repository":"default",
                "uid":"73083c4b-9f06-43ef-b26d-7b05bc845473",
                "properties":{
                "dc:title":"Headquarters",
                "file:content":
                <b>[[batch.asJson]]</b>
                }}</pre>
            </div>
            <div class="ui ribbon label">{{batch.batchId}}</div>
            <textarea>${batch.asJson}</textarea>
          </template>
          <nuxeo-batch-reference readonly="true" selected?="${batch}">
            <div class="empty ui yellow message">
              <div class="content">
                <div class="header">
                  No batches created yet.
                </div>
              </div>
            </div>
          </nuxeo-batch-reference>
          <p class="ui attached message">You can use the <a href="#/uploads">Batch Upload</a> area to create and manage batches.</p>
          ` : ''}
        </div>
      </div>
    `;
    }
  }
}
