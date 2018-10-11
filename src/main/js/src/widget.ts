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
import { when } from 'lit-html/directives/when.js';
import { customElement } from './decorators';

import {
  modal,
  ButtonCSS,
  HeaderCSS,
  IconCSS,
  InputCSS,
  SegmentCSS,
  FormCSS,
  CheckboxCSS,
  DropdownCSS,
  ModalCSS,
  DimmerCSS,
  TransitionCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

@customElement('nuxeo-widget')
export class Widget extends LitElement {

  constructor() {
    super();
  }

  @property() type: string;
  @property() datatype: string;
  @property() required: boolean = false;
  @property() value: any;
  @property() options: string[];
  
  render() {

    return html`
    <style>
      ${ButtonCSS}
      ${HeaderCSS}
      ${IconCSS}
      ${InputCSS}
      ${SegmentCSS}
      ${FormCSS}
      ${CheckboxCSS}
      ${DropdownCSS}
      ${ModalCSS}
      ${DimmerCSS}
      ${TransitionCSS}
      ${StyleCSS}
    </style>

    <div class="ui form">
      ${when(this.datatype == 'document' || this.datatype == 'documents', () => this._picker(), () => this._widget())}
    </div>
    `;
  }

  // Document(s)
  // Note: type is normally 'text' but we also use it to specify the field of the document we want (uid, path, ...) --> 
  _picker() {
    const { datatype, type, value, required } = this;
    return html`
    <div class="ui action input">
      <input id="widget" type="text" value="${value}" ?required="${required}"/>
      <div class="ui icon button" @click="${() => this.showModal()}"><i class="open folder outline icon"></i></div>
    </div>
    <div class="ui modal">
      <i class="close icon"></i>
      <div class="small header">
        Pick ${datatype}:
      </div>
      <div class="content">
        <!-- TODO(nfgs): Do not hardcode max-height -->
        <div class="ui segment" style="max-height:300px;overflow:auto;width:100%">
        <!-- TODO(nfgs): Do not hardcode connectionId -->
        <nuxeo-tree root="/"
                key="${type == 'text' ? 'uid' : type}"
                multipleSelection="${datatype == 'documents'}"
                selected="${value}"></nuxeo-tree>
        </div>
      </div>
      <div class="actions">
        <div class="ui button">Cancel</div>
        <div class="ui button">OK</div>
      </div>
    </div>
    `;
  }

  _widget() {
    const { type, datatype, required, options } = this;
      
    let value = this.value || '';

    switch (type) {
      case 'text':
      case 'integer':
        // Checkbox -->
        if (datatype == 'boolean') {
          return html`
          <div class="ui checkbox">
            <input id="widget" type="checkbox" ?checked=${value} ?required=${required}
              @change="${(e) => this._valueChanged(e)}"/>
            <label for="widget"></label>
          </div>
          `;
        }

        // Text input
        // datatype == 'string' || 'integer' || ... 
        if (datatype != 'boolean' && datatype != 'document' && datatype != 'documents') {
          return html`
          <input id="widget" type="text" value="${value}" .required=${required}
          @change="${(e) => this._valueChanged(e)}"/>`;
        }

      case 'Option':
        return html`
        <select class="ui dropdown selection" .value="${value}" @change="${(e) => this._valueChanged(e)}"/>
          ${options.map((option) => html`<option>${option}</option>`)}
        </select>
        `;

      case 'textarea':
        return html`
        <textarea class="ui textarea" style="height: 20em" id="widget" .value="${value}"
          @change="${(e) => this._valueChanged(e)}"/></textarea>
        `;

      case 'blob':
      case 'bloblist':
        return html`
        <input id="widget" type="file" name="file" @change="${() => this.onFileSelected()}" ?required=${required} ?multiple=${type == 'bloblist'}>
        <div hidden?="${!value}">
          <div>Size: ${value.length}.</div>
        </div>
        `;

      case 'xpath':
        return html`
        <nuxeo-xpath id="widget" value="${value}" ?required=${required} @change="${(e) => this._valueChanged(e)}"></nuxeo-xpath>
        `;
    }
  }

  _valueChanged(e) {
    this.value = e.target.value;
    this.dispatchEvent(new CustomEvent('change', {detail: e.target.value}));
  }

  showModal() {
    modal(this.shadowRoot.querySelector(".ui.modal"));
  }

  get valid(): boolean { return (this.input == null) || this.input.validity.valid; }
  get input(): HTMLInputElement { return this.shadowRoot.querySelector("#widget"); }

  onFileSelected() {
    this._upload(this.input.files).then((files) => {
      if (this.type == "blob") {
        this.value = files[0];
      } else { // bloblist
        if (this.value == null) {
          this.value = [];
        }
        this.value = files;
      }
    });
  }

  _upload(files): Promise<any> {
    return Promise.all(
      files.map((file) => new Promise((resolve, reject) => {
        var reader = new FileReader();
        reader.onloadend = (e) => {
          resolve(e.target.result);
        };
        reader.onerror = (e) => reject(e.error);
        reader.readAsArrayBuffer(file);
      }))
    );
  }
}
