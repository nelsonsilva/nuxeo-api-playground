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
import * as swagger from './swagger';

import { customElement } from './decorators';
import { Widget } from './widget';
import './request-options';
import './request-monitor';

import {
  accordion,
  sidebar,
  ButtonCSS,
  HeaderCSS,
  IconCSS,
  ImageCSS,
  InputCSS,
  LabelCSS,
  SegmentCSS,
  BreadcrumbCSS,
  FormCSS,
  GridCSS,
  MenuCSS,
  MessageCSS,
  TableCSS,
  AccordionCSS,
  DimmerCSS,
  SidebarCSS,
  TransitionCSS,
  ListCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

/// A list of the endpoints to display
const RESOURCE_ENDPOINTS = ["path", "id", "directory", "user", "group", "search", "workflow", "workflowModel", "task", "facet", "schema", "docType"];

const DEFAULT_DOCUMENT_BODY = `
{
  "entity-type": "document",
  "name":"newDoc",
  "type": "File",
  "properties": {
      "dc:title": "A new document",
      "dc:description": "Created via the REST API"
  }
}
`;

const methodColors = {
  "GET": "blue", "POST": "teal", "PUT": "green", "DELETE": "red"
};

/// Wrapper for a [Parameter] to store the current value and make it [Observable].
class ParameterValue {
  
  private _param: swagger.Parameter;
  value: any;

  constructor(param: swagger.Parameter) {
    this._param = param;
  }

  get name() { return this._param.name; }
  get dataType() { return this._param.dataType; }
  get description() { return this._param.description; }
  get type() { return this._param.paramType; }
  get required() { return this._param.required == 'true'; }

  get isPathParam(): boolean { return this.type == 'path'; }
  get isHeaderParam(): boolean { return this.type == 'header'; }
  get isBodyParam(): boolean { return this.type == 'body'; }
  get isQueryParam(): boolean { return this.type == 'query'; }

  get isValid(): boolean {
    return !this.required || (this.required && this.value != null);
  }

  get isEmpty(): boolean {
    return this.value == null || this.value == '';
  }

  get widget(): String {

    // We use the type to specify the field of the document we want to use
    if (this.name == 'docPath') return 'path';
    if (this.name == 'docId') return 'uid';

    if (this.isBodyParam) return 'textarea';

    if (this.dataType == 'string' || this.dataType == 'long') return 'text';

    return this.dataType;
  }
}

@customElement('nuxeo-resource-endpoints')
export class ResourceEndpoints extends ModuleElement {

  @property() endpoint: swagger.Resource;
  @property() operation: swagger.Operation;
  /// List of parameter values
  @property() params: ParameterValue[] = [];

  @property() errors:string[] = [];

  @property() request: Request;
  @property() response: any;

  private endpoints = new Map<string, swagger.Resource>();

  constructor() {
    super('resources');
    this.title = "Resources Endpoints";
    this.icon = "resources_endpoints.png";
    this.description = "Discover the list of REST resources endpoints and try some REST calls to see the result.";
    this.action = "Discover";
  }

  render() {
    const { title, icon, description, endpoints, endpoint, endpointKey, operation, params, request, response, batch, errors } = this;

    return html`
    <style>
      ${ButtonCSS}
      ${HeaderCSS}
      ${IconCSS}
      ${ImageCSS}
      ${InputCSS},
      ${LabelCSS},
      ${SegmentCSS}
      ${BreadcrumbCSS}
      ${FormCSS},
      ${GridCSS},
      ${MenuCSS}
      ${MessageCSS}
      ${TableCSS}
      ${AccordionCSS}
      ${DimmerCSS}
      ${SidebarCSS}
      ${TransitionCSS}
      ${ListCSS}
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

        <!-- Endpoints -->
        <div id="endpoints" class="ui fluid blue accordion" style="overflow:hidden">

          ${endpoints && Object.keys(endpoints).sort().map((key) => html`
            <div class="title">
              <i class="dropdown icon"></i>
              <span style="text-transform:capitalize">${key}</span>
            </div>
            <div class="content" style="padding:0">
              <div class="ui small animated list">
                ${endpoints[key].map((resource, idx) => 
                    resource.operations.map((operation) => html`
                    <div class="item">
                      <div class="content">
                        <a href="/resources/${key}/${idx}/${operation.method}">
                          <span class="ui top left attached ${methodColors[operation.method]} label">${operation.method}</span> ${resource.path}
                        </a>
                      </div>
                    </div>
                    `)
                  )}
              </div>
            </div>
          `)}

          </div>
      </div>
    </div>
    <!-- Button -->
    <div class="ui blue launch right attached button" id="leftmenu" @click="${() => sidebar(this.sidebar, 'toggle')}">
        <i class="reorder icon"></i>
    </div

    <!-- Main page -->
    <div class="ui page grid" id="main-page">
      <div id="main" class="column">

        <!-- Breadcrumb -->
        <div class="ui segment brdcrmb">
         <div class="ui breadcrumb">
          <a class="section" href="/"><i class="ui home icon"></i></a>
          <div class="divider"> / </div>
          <a class="section" href="/">${title}</a>
          ${ endpoint ? html`
            <div class="divider"> / </div>
            <div class="active section">${endpointKey}</div>
            <div class="divider"> / </div>
            <div class="active section">${operation.method}</div>
          ` : ''}
        </div>
       </div>

        ${when(!endpoint,
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
          <div class="ui huge header">${operation.method} /api/v1${endpoint.path}</div>
          <div class="ui description segment">${operation.summary}</div>
          <div class="ui medium blue header">Parameters</div>
          <div class="ui form">

            <table class="ui large blue basic table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Value</th>
                  <th>Description</th>
                  <th>Type</th>
                </tr>
              </thead>
              <tbody>
                ${params.map((param) => html`
                <tr>
                  <td>${param.name}</td>
                  <td>
                    <div class="field">
                      <!-- NOTE: We use the type to specify the field of the document we want to use -->
                      <nuxeo-widget
                        datatype="${(param.name == 'docPath' || param.name == 'docId') ? 'document' : 'string'}"
                        type="${param.widget}"
                        ?required="${param.required}"
                        .value="${param.value}"
                        @change="${(e) => param.value = e.target.value}">
                      </nuxeo-widget>
                    </div>
                    <!-- Copy default body -->
                    ${(operation.method == 'PUT' && param.isBodyParam) ?
                      html`<div class="ui right floated button" @click="${this.setDefaultBody}">Fetch ${param.name}</div>` : ''
                    }
                    <!-- Reference a batch -->
                    ${this._canReferenceBatch(param) ? this._batch(batch) : ''}
                  </td>
                  <td>${param.description}</td>
                  <td>
                  ${when(param.dataType=='document'||param.dataType=='directoryEntries'||param.dataType=='directoryEntry'||param.dataType=='user'||param.dataType=='group',
                    () => html`<a target="alt" _href="http://doc.nuxeo.com/nxdoc/rest-api-entity-types/#{{param.dataType}}">{{param.dataType}}</a>`,
                    () => param.dataType)
                  }
                  <span class="ui small label" style="float:right">${param.type}</span></td>
                </tr>
                `)}
              </tbody>
           </table>
          </div>

          <!-- Run with options -->
          <div id="options" class="ui fluid accordion">
            <div class="title" style="text-align: right;">
            <div class="ui clearing">
             <i class="">Click on Run for executing the request. You can also click on the "settings" icon for adding custom headers to your request. Then click on the "CURL request" tab for seeing the details of the request. </i>
             </div>
              <i class="settings icon"></i>

              <!-- Submit button -->
              <div class="ui red submit button" @click="${(e) => this.runRequest(e)}">Run</div>
            </div>

            <div class="content">
              <nuxeo-request-options .request="${request}"></nuxeo-request-options>
            </div>
          </div>

          ${errors.length ? html`
            <div class="ui bottom attached error message">
              ${errors.map((error) => html`<p><i class="icon warning"></i>${error}</p>`)}
            </div>
            `: ''}
          <br/>

          <!-- Output -->
          ${ response ? html`<nuxeo-request-monitor .request="${request}" .response="${response}"></nuxeo-request-monitor>`: ''}
        
        `)}
      </div>
    </div>
    `;
  }

  /// Triggered when the connection is established
  onActivate() {
    Promise.all(
     RESOURCE_ENDPOINTS.map((resourceKey) => {
      
      // Execute the method (does not handle the response)
      return this.client.request(`doc/${resourceKey}.json`).get()
      .then((res) => {
        this.endpoints[resourceKey] = res.apis;
        this.requestUpdate();
      })
      .catch((e) => {
        console.log(`Endpoint '${resourceKey}' not available.`);
      });
    }))
    // After everything is loaded
    .then(() => {
      if (this._route) {
        const [endpoint, idx, method] = this._route;
        this.route(endpoint, idx, method);
      }
    });

  }

  get sidebar() { return this.shadowRoot.querySelector('.ui.sidebar'); }

  firstUpdated() {
    sidebar(this.sidebar, 'show');
  }

  updated() {
    accordion(this.shadowRoot.getElementById('endpoints'))
    accordion(this.shadowRoot.getElementById('options'));
  }

  route(endpoint, idx = '0', method = 'GET') {

    if (!endpoint || !this.endpoints || !Object.keys(this.endpoints).length ) {
      this.operation = this.endpoint = undefined;
      return;
    }

    this.endpoint = this.endpoints[endpoint][parseInt(idx)];
    this.operation = this.endpoint && this.endpoint.operations.find((o) => o.method == method);

    // Setup the parameters
    
    // Add all except header params
    if (this.operation) {
      this.params = this.operation.parameters.map((p) => new ParameterValue(p)).filter((p) => !p.isHeaderParam);
    }

    // Clear request and response
    this._reset();

    this.request = this.client.request(endpoint.path);
  }

  _canReferenceBatch(param) {
    const { operation, endpointKey } = this;
    return (param.name == 'document' && (endpointKey == 'id' || endpointKey == 'path') && (operation.method == 'POST' || operation.method == 'PUT'));
  }

  _batch(batch) {
    
    const sample ={
      "entity-type":"document",
         "repository":"default",
         "uid":"73083c4b-9f06-43ef-b26d-7b05bc845473",
         "properties":{
            "dc:title":"Headquarters",
            "file:content": batch.asJson
         }
      };

    return html`
    <div class="ui right floated button" @click="${this.referenceBatch}">Reference a Batch</div>
      <div class="ui modal" style="width: auto;">
        <i class="close icon"></i>
        <div class="header">
          Select a batch. 
        </div>
        <div class="content">
          ${batch ? html`
          <div class="field">Copy paste the JSON string below and report it on the document object you want to create<br/> or update, for the file property for which you want to upload a file, ex:<br/>
            <pre>${sample}</pre>
          </div>
          <div class="ui ribbon label">${batch.batchId}</div>
          <textarea>${batch.asJson}</textarea>
        `: ''}
        <nuxeo-batch-reference readonly="true" selected="${batch}">
          <div class="empty ui yellow message">
            <div class="content">
              <div class="header">
                No batches created yet.
              </div>
            </div>
          </div>
        </nuxeo-batch-reference>
        <p class="ui attached message">You can use the <a href="/uploads">Batch Upload</a> area to create and manage batches.</p>
      </div>
    </div>
    `;
  }

  /// Executes the requests.
  runRequest(e) {

    // don't submit the form
    e.stopImmediatePropagation();
    e.preventDefault();

    // Clear request and response
    this._reset();

    const widgets: Widget[] = Array.from(this.shadowRoot.querySelectorAll("nuxeo-widget"));
    let valid = widgets.every((w) => w.valid);

    if (!valid) {
      this.errors.push("Invalid form values!");
      return;
    }

    let path = this.endpoint.path;

    // replace parameters
    this.params.filter((p) => p.isPathParam).forEach((param) => {
      path = path.replace(`{${param.name}}`, (param.value == null)? "" : param.value);
    });

    // Query parameters
    var queryParams = this.params
        .filter((p) => p.isQueryParam && !p.isEmpty)
        .map((param) => `${param.name}=${encodeURIComponent(param.value)}`)
        .join("&");

    var bodyParam = this.params.filter((p) => p.isBodyParam);

    var body = (bodyParam.length == 0) ? undefined : bodyParam[0].value;

    // Call the op using 'execute' which does not handle the response
    return this.client.request(path).queryParams(queryParams)
    .execute({
      method: this.operation.method,
      body: body,
      resolveWithFullResponse: true
    })
    .then((res) => { this.response = res; })
    .catch((e) => {
      // Store the response
      this.response = e.response;
      this.errors.push(e.message);
     });
  }

  /// Clear request, response and errors
  _reset() {
    this.response = null;
    this.errors = [];
  }

  get endpointKey() {
    return Object.keys(this.endpoints).find((k) => this.endpoints[k].includes(this.endpoint));
  }

  select(event, detail, target) {
    var parts = target.dataset["target"].split("/");
    this.router.go("$path.rest", {"endpoint": parts[0], "idx": parts[1], "method": parts[2]});
  }

  referenceBatch(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    // modal('.ui.modal');
  }

  /// Perform a GET request with the given parameters to get a default value for the body (if any)
  setDefaultBody() {
    const { params, endpoint } = this;

    var bodyParam = params.find((p) => p.isBodyParam);

    let path = endpoint.path;

    // replace parameters
    params.filter((p) => p.isPathParam).forEach((param) => {
      path = path.replace("{${param.name}}", (param.value == null)? "" : param.value);
    });

    // Call the op using 'execute' which does not handle the response
    this.client.request(path).execute({method: 'GET'})
    .then((res) => { bodyParam.value = res.body; })
    .catch((e) => {
      this.errors.push(e.message);
     });
  }
}
