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
  InputCSS,
  LabelCSS,
  SegmentCSS,
  BreadcrumbCSS,
  FormCSS,
  GridCSS,
  MenuCSS,
  TableCSS,
  AccordionCSS,
  ListCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

@customElement('nuxeo-command-endpoints')
export class CommandEndpoints extends ModuleElement {

  @property() operations = {};

  // SearchFilter
  @property() searchTerm = '';
  //@property() searchFilter = '';

  // Tracing
  @property() canManageTraces = false;
  @property() tracesEnabled = false;

  @property() selectedOp?: string;

  constructor() {
    super('commands');
    this.title = "Command Endpoint";
    this.icon = "command_endpoints.png";
    this.description = "Browse the list of Automation operations and chains deployed on the server you are connected to. Try some automation calls, filling expected parameters and input.";
    this.action = "Discover";
    this.errors = [];
  }

  render() {

    const { title, icon, description, categories, operations, searchTerm, selectedOp } = this;
    return html`
  
    <style>
      ${ButtonCSS}
      ${HeaderCSS}
      ${IconCSS}
      ${ImageCSS}
      ${InputCSS}
      ${LabelCSS}
      ${SegmentCSS}
      ${BreadcrumbCSS}
      ${FormCSS}
      ${GridCSS}
      ${MenuCSS}
      ${TableCSS}
      ${AccordionCSS}
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
      <!-- Search -->
      <div class="item">
        <div class="ui icon input">
          <input type="search" class="form-control" value="${searchTerm}" placeholder="Search...">
          <i class="search icon"></i>
        </div>
      </div>
      <!-- Operations -->
      <div id="operations" class="ui fluid blue accordion" style="overflow:hidden">
        ${categories.map(category => html `
          <div class="title">
            <i class="dropdown icon"></i>
            ${category}
          </div>
          <div class="content" style="padding:0">
            <div class="ui small animated list">
              ${operations[category].filter(this.searchFilter).sort(this.sortBy('label')).map(op => html`
                <div class="item">
                  <div class="content">
                    <a href="/${this.id}/${op.id}">${op.label}</a>
                  </div>
                </div>
              `)}
            </div>
          </div>
        `)}
      </div>
    </div>
  </div>
    <!-- Button -->
    <div class="ui blue launch right attached button" id="leftmenu" @click="${() => sidebar(this.sidebar, 'toggle')}">
      <i class="reorder icon"></i>
    </div>
    <!-- Main page -->
    <div class="ui page grid" id="main-page">
      <div class="column">

        <!-- Breadcrumb -->
        <div class="ui segment brdcrmb">
         <div class="ui breadcrumb">
          <a class="section" href="/"><i class="ui home icon"></i></a>
          <div class="divider"> / </div>
          <a class="section" href="/commands">${title}</a>
          ${selectedOp ? html `
            <div class="divider"> / </div>
            <div class="active section">${selectedOp}</div>
          ` : ''}
        </div>
       </div>

        ${when(selectedOp,
        () => html `<nuxeo-operation opid="${selectedOp}"></nuxeo-operation>`,
        () => html`
          <div class="ui raised segment">
            <h3 class="ui blue header">${title}</h3>
            <div class="ui grid">
              <div class="four wide column"><img class="ui medium image" src="../images/${icon}"></div>
              <div class="twelve wide column">
                <p class="description">${description}</p>
              </div>
            </div>
          </div>
        `)}
      </div>
    </div>
    `;
  }

  get sidebar() { return this.shadowRoot.querySelector('.ui.sidebar'); }

  firstUpdated() {
    sidebar(this.sidebar, 'show');
  }

  async onActivate() {
    this.operations = {};

    // Get the op registry
    let registry = await this.client.http({url: this.client._automationUrl});
    
    // Get the ops
    Object.entries(registry).forEach(([name, op]) => {
      if (!this.operations[op['category']]) {
        let ops = this.operations[op['category']] = [];
        ops.push(op);
      }
    })
  
    accordion(this.shadowRoot.querySelector(".ui.accordion"));

  }

  searchFilter(e) {
    return e;
  }
  
  sortBy(key: string) {
    return (a,b) => a[key] > b[key];
  }

  //@ObserveProperty("module.selectedOp")
  //updateOperation() {
  //  this.selectedOp = (module != null) ? (module as CommandEndpoints).selectedOp : null;
  //}

  /// Returns filtered categories with at least one operation.
  get categories() { return Object.keys(this.operations).filter((c) => this.filter(this.searchFilter)(this.operations[c].length)); }

  filter(term, key = 'label') {
    return (items) => term == '' ? items : items.filter((i) => i[key].toLowerCase().contains(term.toLowerCase()));
  }
  //labelFor(item) => item.label;

  /// Called when the searchFilter changes
  searchFilterChanged() {
    //notifyPropertyChange(#categories, null, categories);
    accordion(this.shadowRoot.querySelector(".ui.accordion"));
  }

}
