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
import { when } from 'lit-html/directives/when';

import 'nuxeo/nuxeo.js';
import * as Cookies from 'js-cookie';
import { customElement } from './decorators';

import { ButtonCSS, IconCSS, ImageCSS, LabelCSS, SegmentCSS, FormCSS, GridCSS, MessageCSS } from './semantic';
import { StyleCSS } from './shared-styles';

// A global map of clients with connectionId as key.
// This map is shared between all instances of nuxeo-connection.
const CLIENTS = new Map<string, Nuxeo>();

declare global {
  interface Event {
    composedPath(): EventTarget[];
  }
}

export const Connected = (baseElement: any) => class extends baseElement {

  client?: Nuxeo;

  static get properties() {
    return {
      connectionId: { type: String, value: ''},
      isConnected: { type: Boolean, value: false}
    }
  }

  constructor() {
    super();
    let client = CLIENTS.get(this.connectionId);
    if (client && client.connected) {
      this.__onConnected(client);
    }
  }

  __onConnected(client: Nuxeo) {
    this.client = client;
    this.isConnected = client.connected;
    this.onConnected && this.onConnected(client); 
  }

  connectedCallback() {
    window.addEventListener('connected', (e: Event) => {
      this.__onConnected((e.composedPath()[0] as Connection).client);
    });
    if (super.connectedCallback) {
      super.connectedCallback();
    }
  }
  
};

@customElement('nuxeo-connection')
class Connection extends LitElement {

  client: any;
  @property() connectionId: string = '';
  @property() isConnected: boolean = false;
  @property() nuxeoUrl: string = 'http://localhost:8080';
  @property() username?: string;
  @property() password?: string;
  @property() alerts: Array<string> = [];
      
  render() {
    const { isConnected, nuxeoUrl, username, password, alerts } = this;
    return html`

    <style>
      ${ButtonCSS}
      ${IconCSS}
      ${ImageCSS}
      ${LabelCSS}
      ${SegmentCSS}
      ${FormCSS}
      ${GridCSS}
      ${MessageCSS}
      ${StyleCSS}
    </style>
    
    <div class="connection">
      <div class="ui page grid">

        <!-- TODO - Make this the same size as the sidebar button  -->
        <div class="column connectblock">

          <!-- Not connected -->
          ${ when(isConnected,
            () => html`
            <div style="float:right">
             ${username}, connected to <a _href="${nuxeoUrl}" target="alt">${nuxeoUrl}</a>
              <div class="ui blue button" @click="${this.disconnect}">Sign out</div>
            </div>
            `,
            () => html`
            <h1>Discover Nuxeo Platform API</h1>

            <p>Connect the playground with a Nuxeo Platform server and browse the repository, the data structures, as well as the resources and command endpoints. Understand which attributes are expected, as well as which headers can be used by performing real tests.</p>

            <div class="ui form attached segment">
              <div class="ui grid">
                <div class="row">
                <div class="seven wide column">
                  <input placeholder="http://localhost:8080/nuxeo" type="text" value="${nuxeoUrl}" @change="${e => this.nuxeoUrl = e.target.value}">
                </div>
                <div class="three wide column">
                  <input placeholder="Login" type="text" value="${username}" @change="${e => this.username = e.target.value}">
                </div>
                <div class="three wide column">
                  <input placeholder="Password" type="password" value="${password}" @change="${e => this.password = e.target.value}">
                </div>
                <div class="three wide column">
                  <div class="ui fluid blue button" @click="${() => this.connect()}">Connect</div>
                </div>
                </div>
              </div>
            </div>

            ${ alerts.length > 0 ? html`
              <div class="ui bottom attached warning message">
                 <div class="ui top right attached small label" style="font-size:.6rem;">
                  make sure you activated the <a href="http://doc.nuxeo.com/nxdoc/cross-origin-resource-sharing-cors" target="_blank">CORS config</a> on your Nuxeo server
                </div>
                ${alerts.map((alert) => html`<i class="icon warning"></i>${alert}<br/>`)}
              </div>
            ` : ''}
          `
          )}
        </div>
      </div>
    </div>
    `;
  }

  static clients() {
    return CLIENTS;
  } 

  constructor() {
    super();

    this.nuxeoUrl = 'http://localhost:8080/nuxeo'
    this.username = 'Administrator';
    this.password = 'Administrator';
    this.alerts = [];

    // Support auto connecting to server using hash fragment as url
    // ex: (#/http://localhost:8080/nuxeo)
    if (window.location.hash.startsWith("#/http")) {
      this.nuxeoUrl = window.location.hash.substring(2);
      this.client = new Nuxeo({baseURL: this.nuxeoUrl});
    }
    // Check if we have any token stored as a cookie
    const token = Cookies.get('X-Authentication-Token');
    if (token) {
      this.nuxeoUrl = Cookies.get('Nuxeo-URL');
      this.client = new Nuxeo({
        baseURL: this.nuxeoUrl,
        schemas: ["*"],
        auth: {
          method: 'token',
          token: token
        }
      });
    }

    CLIENTS.set(this.connectionId, this.client); 
    this.client && this._login();
  }

  /// Connect to the server
  connect() {

    this.alerts = [];

    this.client = new Nuxeo({
      baseUrl: this.nuxeoUrl,
      auth: {
        method: 'basic',
        username: this.username,
        password: this.password
      }
    });

    return this._login()
    .then(() => this._getToken()) // Try to get a token and if succeed store it as a cookie along with the URL
    .then((token) => {
      Cookies.set('X-Authentication-Token', token);
      Cookies.set('Nuxeo-URL', this.nuxeoUrl);
    });
    
    /*
    ;*/
  }


  _login(): Promise<any> {
    return this.client.connect()
    .then((client: Nuxeo) => {
      this.isConnected = client.connected;
      this.username = client.user.id;

      this.dispatchEvent(new CustomEvent('connected', {bubbles: true, composed: true}));
     })
    .catch(() => {
      this.alerts.push('Please check the Nuxeo URL and try connecting again.');
    });
  }

  /// Get a token that can be used for authentication
  _getToken() {
    const app = 'Nuxeo API Playground';
    const deviceId = `device-${Math.floor(Math.random() * 1000)}`;
    const deviceDescription = deviceId;
    return this.client
      .http({
        url: `${this.nuxeoUrl}/authentication/token?applicationName=${app}&deviceId=${deviceId}&deviceDescription=${deviceDescription}&permission=rw`,
        headers: {
          'X-No-Basic-Header': 'true'
        }
      })
      .then((res) => res.text())
  }

  /// Disconnects from the server and removes any cookies.
  disconnect() {
    Cookies.remove("X-Authentication-Token");
    Cookies.remove("Nuxeo-URL");
    this.isConnected = false;
  }

  onConnected() {
    // Check if we can toggle tracing if so set the default traing level
   this._toggleTraces();
  }

  /// Tracing

  /// Checks if we can manage traces
  _toggleTraces() {
    return this.client.http('/site/automation/doc/traces?opId=')
    .then((res) => {
      if (res.body != "You can not manage traces") {
        return this.client.operation('Traces.ToggleRecording').params({"enableTrace": true}).execute();
      }
    });
  }
   
  getTrace(op: string): Promise<string> {
    return this.client.http(`/site/automation/doc/traces?opId=${op})`).then((res) => res.body);
  }
  

  /*
  Map<String, String> _parseQuery() {
    var params = <String,String>{};
    var queryStr = window.location.search;
    if (queryStr.startsWith('?')) {
      queryStr = queryStr.substring(1);
      queryStr.split('&').forEach((String keyValPair) {
        List<String> keyVal = keyValPair.split('=');
        var key = keyVal[0];
        if (key.isNotEmpty) {
          params[key] = Uri.decodeComponent(keyVal[1]);
        }
      });
    }
    return params;
  }
  */
}
