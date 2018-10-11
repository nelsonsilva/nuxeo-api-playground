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
import { customElement } from './decorators';

import {
  IconCSS,
  InputCSS,
  FormCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

const HEADER_NX_VOIDOP = "X-NXVoidOperation";
const HEADER_NX_VERSIONING_OPTION = "X-Versioning-Option";

@customElement('nuxeo-request-options')
class RequestOptions extends LitElement {
  @property() request: Request;

  render() {
    const { request } = this;
    const options = request._baseOptions;
    //const timeout = options.timeout; // TODO: | inSeconds;
    //const schemas = options.schemas; // TODO: | asCSV
    return html`
    <style>
      ${IconCSS}
      ${InputCSS}
      ${FormCSS}
      ${StyleCSS}
    </style>
      
    <div class="ui form">
      <div class="two fields">
        <div class="field"><label>X-NXVoidOperation</label></div>
        <div class="field">
          <input type="checkbox" .checked="${request}">
        </div>
      </div>
      <div class="two fields">
        <div class="field"><label>Nuxeo-Transaction-Timeout <i class="help icon" title="This header can be used when you want to control the transaction duration. As an example, if you want to inject a large blob
in the repository, the default transaction timeout may be not enough. You can specify a 5 minutes timeout for the chain you're executing :
Nuxeo-Transaction-Timeout: 300"></i></label> </div>
        <div class="field"><input type="text" value="${options.timeout || ''}" @change="${(e) => options.timeout = e.target.value}"></div>
      </div>
      <div class="two fields">
        <div class="field"><label>X-NXproperties <i class="help icon" title="This header can be used whenever a Document will be returned by the server.
The header is forcing the server to fill up the returned document with data from schemas that matches the X-NXDocumentProperties filter.
If you don't use the header only the minimal required properties of the document are returned.
To have more properties in the returned document, you can specify a list of document schema names:
X-NXDocumentProperties: dublincore, file
or to have all the document content, you can use the '*' character as the filter value:
X-NXDocumentProperties: *"></i></label></div>
        <div class="field"><input type="text" value="${options.schemas || ''}" @change="${(e) => options.schemas = e.target.value.split(',')}"></div>
      </div>
      <div class="two fields">
        <div class="field"><label>X-NXRepository<i class="help icon" title="This header can be used to when you need to access a specific repository. The default value is 'default', as it's the default repository name in Nuxeo. This is handy if you have change the default name or if you have multiple repositories.
X-NXRepository: myCustomRepositoryName"></i></label></div>
        <div class="field"><input type="text" value="${options.repositoryName || ''}" @change="${(e) => options.repositoryName = e.target.value}"></div>
      </div>
      <div class="two fields">
        <div class="field"><label>X-NXVersioningOption<i class="help icon" title="This header can be used when you need to increment the minor or major version and return the versioned document. By default, no version checkin is done and 'live' (snapshot) document is returned."></i></label></div>
        <div class="field">
          <select value="${options.headers[HEADER_NX_VERSIONING_OPTION] || ''}" @change="${(e) => options.headers[HEADER_NX_VERSIONING_OPTION] = e.target.value}">
            <option value="NONE">NONE</option>
            <option value="MAJOR">MAJOR</option>
            <option value="MINOR">MINOR</option>
          </select>
        </div>
      </div>
      <div class="two fields">
        <div class="field"><label>X-NXfetch.document<i class="help icon" title="This header can be used to load additional parts of an object whose entity-type is document."></i></label></div>
        <div class="field"><input type="text" value="${options.fetchProperties.document || ''}" @change="${(e) => options.fetchProperties.document = e.target.value}"></div>
      </div>
    </div>
    `;
  }
}
