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
import { accordion, sidebar } from './semantic';
import { customElement } from './decorators';
import { Doctype, Schema, Facet, fetchTypes } from './doctypes';
import { DiagramGenerator } from './yuml';
import './tree'
import './widget';

import {
  HeaderCSS,
  IconCSS,
  ImageCSS,
  InputCSS,
  LabelCSS,
  SegmentCSS,
  BreadcrumbCSS,
  GridCSS,
  MenuCSS,
  TableCSS,
  AccordionCSS,
  SidebarCSS,
  TransitionCSS,
  ListCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

@customElement('nuxeo-structures-browser')
export class StructuresBrowser extends ModuleElement {

  /// A map with a list of [nuxeo.Doctypes]s, [nuxeo.Facet]s and [nuxeo.Schema]s.
  @property() items = {
    schemas: [],
    facets: [],
    types: []
  };

  @property() selectedType: string;
  @property() selectedId: string;

  _diagram: DiagramGenerator;

  constructor() {
    super('data');
    this.title = "Data Structures";
    this.icon = "data_structure.png";
    this.description = "Browse all the definitions of types, schemas (with their properties) and facets that are configured on the Nuxeo Platform server you are connected to.";
    this.action = "Browse";
    this.errors = [];
  }

  render() {
    const { title, icon, description, items, searchTerm, selectedId, selectedType } = this;

    let selectedItem = (selectedId != null && items[selectedType].length) ? items[selectedType].find((d) => d.name == selectedId) : undefined;

    return html`
    <style>
      ${HeaderCSS}
      ${IconCSS}
      ${ImageCSS}
      ${InputCSS}
      ${LabelCSS}
      ${SegmentCSS}
      ${BreadcrumbCSS}
      ${GridCSS}
      ${MenuCSS}
      ${TableCSS}
      ${AccordionCSS}
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
        <!-- Search -->
        <div class="item">
          <div class="ui icon input">
            <input type="search" class="form-control" value="${searchTerm}" placeholder="Search...">
            <i class="search icon"></i>
          </div>
        </div>

        <!-- Schemas, Facets and Doctypes -->
        <div id="datastructures" class="ui fluid blue accordion" style="overflow:hidden">

          ${Object.keys(items).map(type => html`
            <div class="title">
                <i class="dropdown icon"></i>
                ${type}
              </div>
              <div class="content" style="padding:0">
                <div class="ui small animated list">
                  ${items[type].filter(this.searchFilter).sort(this.sortBy('name')).map(item => html `
                    <div class="item">
                      <div class="content">
                        <a href="/data/${type}/${item.name}">${item.name}</a>
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
      <div id="main" class="column">

        <!-- Breadcrumb -->
        <div class="ui segment brdcrmb">
         <div class="ui breadcrumb">
          <a class="section" href="/"><i class="ui home icon"></i></a>
          <div class="divider"> / </div>
          <a class="section" href="/${this.id}">${title}</a>
          ${selectedItem ? html`
            <div class="divider"> / </div>
            <div class="active section">${selectedType}</div>
            <div class="divider"> / </div>
            <div class="active section">${selectedItem.name}</div>
          `: ''}
        </div>
       </div>

        ${when(!selectedItem,
          () => html `
            <div class="ui raised segment">
              <h3 class="ui blue header">${title}</h3>
              <div class="ui grid">
                <div class="four wide column"><img class="ui medium image" src="../images/${icon}"></div>
                <div class="twelve wide column">
                  <p class="description">${description}</p>
                </div>
              </div>
            </div>`,
          () => html `
            <div class="ui huge header">${selectedItem.name}</div>
            ${this.renderItem(selectedItem)}
         `)}
      </div>
    </div>
    `;
  }

  renderItem(item) {
    // SCHEMA 
    if (this.isSchema(item)) {
      return html`
        ${item.prefix ? html`<div class="ui gutter label">PREFIX: ${item.prefix}</div>`: ''}
        <nuxeo-schema schema="${item}"></nuxeo-schema>
      `;

    // FACET
    } else if (this.isFacet(item) && item.schemas.length) {
      return html`
        <i class="sitemap icon link" @click="${() => this.showDiagram(item)}"></i>
        <div class="ui medium header">Related schemas</div>
        ${item.schemas.map((schema) => html `
          <a class="link" href="/${this.id}/schemas/${schema}">${schema}</a>
        `)}
      `;
    
    // DOCTYPE
    } else if (this.isDoctype(item)) {
      return html`
        <i class="sitemap icon link" @click="${() => this.showDiagram(item)}"></i>
        ${item.parent ? html`
          <div class="ui label">
            EXTENDS: <a href="/${this.id}/types/${item.parent}">${item.parent}</a>
          </div>
        `: ''}

        <!-- Schemas -->
        ${item.schemas.length ? html`
          <div class="ui medium header">Schemas</div>
          ${item.schemas.map(schema => html `<a class="link" href="/${this.id}/schemas/${schema}">${schema}</a>`)}
        `: ''}

        <!-- Facets -->
        ${item.facets.length ? html`
          <div class="ui medium header">Facets</div>
          ${item.facets.map(facet => html `<a class="link" href="/${this.id}/facets/${facet}">${facet}</a>`)}
        ` : ''}
      `;
    }
  }

  get sidebar() { return this.shadowRoot.querySelector('.ui.sidebar'); }

  firstUpdated() {
    sidebar(this.sidebar, 'show');
  }

  searchFilter(e) {
    return e;
  }
  
  sortBy(key: string) {
    return (a,b) => a[key] > b[key];
  }

  async onActivate() {

    this.items = await fetchTypes(this.client);
    const { types, schemas, facets } = this.items;
    

    // Setup the accordion
    accordion(this.shadowRoot.querySelector(".ui.accordion"));
    
    // Setup the diagram generator
    this._diagram = new DiagramGenerator(types, schemas, facets);

    // Check for a selected item
    // this.updateSelection();
  }

  route(type, id) {
    this.selectedType = type;
    this.selectedId = id;
  }

  isDoctype(item): boolean { return item != null && (item instanceof Doctype); }
  isFacet(item): boolean { return item != null && (item instanceof Facet); }
  isSchema(item): boolean { return item != null && (item instanceof Schema); }

  /// Open a window with the Diagram of the selected item.
  showDiagram(item) {
    
    if (!item) {
      return;
    }

    let diagram;

    // Update the UI
    if (this.isDoctype(item)) {
      diagram = this._diagram.generateForDoctype(item.name);
    } else if (this.isFacet(item)) {
      diagram = this._diagram.generateForFacet(item.name);
    } else if (this.isSchema(item)) {
      diagram = this._diagram.generateForSchema(item.name);
    }

    var options = `top=0,left=0,width=${window.screen.width},height=${window.screen.height}`;
    window.open(diagram, item.name, options);
  }

  searchFilterChanged() {
    accordion(this.shadowRoot.querySelector(".ui.accordion"));
  }

}
