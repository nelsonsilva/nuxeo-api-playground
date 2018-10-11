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
import { installRouter } from 'pwa-helpers/router.js';
import { updateMetadata } from 'pwa-helpers/metadata.js';
import { Connected } from './connection';
import { ResourceEndpoints } from './resource-endpoints';
import { CommandEndpoints } from './command-endpoints';
import { RepositoryBrowser } from './repository-browser';
import { StructuresBrowser } from './structures-browser';
import { BatchUploads } from './batch-uploads';
import { ModuleElement } from './module-element';
import { customElement } from './decorators';

import { GridCSS, ButtonCSS, ImageCSS, SegmentCSS } from './semantic';
import { StyleCSS } from './shared-styles';

const MODULES = [
  new RepositoryBrowser(),
  new StructuresBrowser(),
  new ResourceEndpoints(),
  new CommandEndpoints(),
  new BatchUploads(),
];

@customElement('nuxeo-playground')
class Playground extends Connected(LitElement) {
  
  @property() _module: ModuleElement;

  render() {
    const {_module, isConnected} = this;

    return html`
    
    <style>
      header {
        position: fixed;
        top: 0;
        left: 0;
        padding: 1em 2em 0;
        right: 0;
        background-color: #fff;
        z-index: 1000;
        height: 60px;
        box-sizing: border-box;
        box-shadow: 0 1px 3px rgba(0,0,0,0.4);
      }

      #logo {
        background:transparent url('images/nuxeo_logo.png') no-repeat;
        background-size: cover;
        display: inline-block;
        height:30px;
        width:160px;
      }

      header span {
        color: #0066FF;
        font-size: 1.8em;
        vertical-align: top;
        padding: 0 0 0 1em;
      }

      ${GridCSS}
      ${ButtonCSS}
      ${ImageCSS}
      ${SegmentCSS}
      ${StyleCSS}
    </style>

    <nuxeo-connection></nuxeo-connection>

    <header>
      <a href="/" id="logo"></a>
      <span class="">API Playground</span>
    </header>

    <!-- Home -->
    ${(!_module) ? html`
      <div class="ui two column stackable wide page grid">
        ${MODULES.map((module) => html`
          <div class="column">
            <div class="ui raised segment">
              <h3 class="ui blue header">${module.title}</h3>
              <div class="ui grid">
                <div class="four wide column"><img class="ui medium image" src="images/${module.icon}"></div>
                <div class="twelve wide column">
                  <p class="description">${module.description}</p>
                  ${ when(isConnected,
                    () => html`<div class="ui right floated blue button" @click="${() => this.navigate(module.id)}">${module.action}</div>`,
                    () => html`<div class="ui right floated disabled button">${module.action}</div>`
                  )}
                </div>
              </div>
            </div>
          </div>
          `)}
      </div>
    `: ''}

    ${MODULES}

    <div class="ui page grid site-footer">
        <div class="ui five stackable column grid">
          <div class="row">
            <div class="column">
              <ul>
                  <li><a href="http://www.nuxeo.com/products/">Products</a></li>
                  <ul class="sub">
                    <li><a href="http://www.nuxeo.com/products/content-management-platform/">Nuxeo Platform</a></li>
                    <li><a href="http://www.nuxeo.com/products/nuxeo-cloud/">Nuxeo Cloud</a></li>
                    <li><a href="http://www.nuxeo.com/products/document-management/">Document Management</a></li>
                    <li><a href="http://www.nuxeo.com/products/digital-asset-management/">Digital Asset Management</a></li>
                    <li><a href="http://www.nuxeo.com/products/case-management/">Case Management</a></li>
                    <li><a href="http://www.nuxeo.com/products/pricing/">Pricing</a></li>
                  </ul>
              </ul>
              <div id="copyright">@ 2018 Nuxeo</div>
            </div>
            <div class="column">
              <ul>
                  <li><a href="http://www.nuxeo.com/services/">Services</a></li>
                  <ul class="sub">
                    <li><a href="http://www.nuxeo.com/services/support/">Support</a></li>
                    <li><a href="http://www.nuxeo.com/services/training/">Training</a></li>
                    <li><a href="http://www.nuxeo.com/services/consulting/">Consulting</a></li>
                  </ul>
              </ul>
            </div>
            <div class="column">
              <ul>
                  <li><a href="http://www.nuxeo.com/customers/">Customers</a></li>
                  <li><a href="http://www.nuxeo.com/partners/">Partners</a></li>
              </ul>
            </div>
            <div class="column">
              <ul>
                  <li><a href="/resources">Learning</a></li>
                  <ul class="sub">
                    <li><a href="http://www.nuxeo.com/resources/">Resources</a></li>
                    <li><a href="http://www.nuxeo.com/events/">Events</a></li>
                    <li><a href="http://www.nuxeo.com/blog/">Blogs</a></li>
                    <li><a href="http://doc.nuxeo.com">Documentation</a></li>
                    <li><a href="http://answers.nuxeo.com/">Answers</a></li>
                    <li><a href="http://nuxeo.github.io/">GitHub</a></li>
                  </ul>
              </ul>
            </div>
            <div class="column">
              <ul>
                  <li><a href="http://www.nuxeo.com/about/">About Us</a></li>
                  <ul class="sub">
                    <li><a href="http://www.nuxeo.com/about/leadership/">Leadership</a></li>
                    <li><a href="http://www.nuxeo.com/media-center/">Media Center</a></li>
                    <li><a href="http://www.nuxeo.com/careers/">Careers</a></li>
                    <li><a href="http://www.nuxeo.com/about/contact/">Contact</a></li>
                  </ul>
                  <li><a href="http://connect.nuxeo.com">My Connect</a></li>
              </ul>
            </div>
        </div>
      </div>
    </div>
    `;
  }

  constructor() {
    super();
  }

  firstUpdated() {
    installRouter((_) => this._locationChanged());
    this.removeAttribute('unresolved');
  }

  update(changedProps) {
    super.update(changedProps);
    if (changedProps.has('_module')) {
      let title = 'Nuxeo API Playground';
      let description = 'Nuxeo API Playground';
      if (this._module) {
        title = [title, this._module.title].join(' - ');
        description = [description, this._module.title].join(' - ');
      }
      updateMetadata({title, description});
    }
  }
  
  navigate(href) {
    window.history.pushState({}, '', href);
    this._locationChanged();
  }

  _locationChanged() {
    const path = decodeURIComponent(window.location.pathname);
    const [id, ...rest] = path.slice(1).split('/');
   
    MODULES.forEach((m) => m.active = (m.id == id));

    this._module = MODULES.find((m) => m.active);

    if (this._module) {
      this._module._locationChanged();
    }
  }
}
