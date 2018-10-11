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
import { Connected } from './connection';
import { customElement } from './decorators';
import {
  accordion,
  IconCSS,
  ImageCSS,
  LabelCSS,
  AccordionCSS
} from './semantic';

const DEFAULT_ICON = "icons/folder.gif";
const DOCTYPE_ICONS = {
  "File": "icons/file.gif",
  "Folder": "icons/folder.gif",
  "Domain": "icons/domain.gif",
  "Workspace": "icons/workspace.gif",
  "Note": "icons/note.gif"
};


@customElement('nuxeo-tree-node')
class Node extends Connected(LitElement) {

  @property() doc: any;
  @property() docs: any[] = [];

  render() {
    const { doc, docs } = this;
    let icon = (doc && DOCTYPE_ICONS[doc.type]) || DEFAULT_ICON;
    let isFolderish = (doc != null) && doc.facets.includes('Folderish');
    return html`
    <style>
    ${IconCSS}
    ${ImageCSS}
    ${LabelCSS}
    ${AccordionCSS}
    .ui.tree.accordion {
      background-color: transparent;
      -webkit-box-shadow: none;
      box-shadow: none;
      max-width: none;
      width: auto;
    }
    .ui.tree.accordion .title,
    .ui.tree.accordion .accordion .title {
      background-color: transparent;
      border-top: none;
      padding: .3em 0;
      color: #203f7d;
    }
    .ui.tree.accordion .content,
    .ui.tree.accordion .accordion .content {
      padding: 0 .3em 0 .6em;
    }
    .ui.tree.accordion .active.title,
    .ui.tree.accordion .accordion .active.title {
      background-color: transparent;
    }
    .ui.tree.accordion .selected {
      color: #00adff;
    }
    </style>
    <div class="ui tree accordion">
      <div class="title">
        ${isFolderish ? html`<i class="icon" on-click="{{toggle}}"></i>`: ''}
        <span class="label" on-click="${(e) => this.toggleSelection(e)}"><img class="tiny image" src="${icon}"> ${doc.title}</span>
      </div>

      <div class="content">
        ${docs.map(doc => html`<nuxeo-tree-node docid="${doc.uid}"></nuxeo-tree-node>`)}
      </div>
    </div>
    `;
  }

    
  firstUpdated() {
    this.shadowRoot.querySelector(".icon").classes.add("expand");
    accordion(this.shadowRoot.querySelectorAll(".ui.accordion"));
  }

  get isFolderish() { return true; }

  set docid(docid) {
    this.client.repository().fetch(docid).then(doc => {
      // TODO: remove this hack - the goal is to have a nice title for the root document
      if (doc.path == '/') doc.title = '/';
      this.doc = doc;
    });
  }

  // Only render if doc is set
  shouldUpdate(changedProps) {
    return !!this.doc;
  }

  async _fetchChildren(){
    if (this.docs.length > 0) {
      return Promise.resolve(this.docs);
    }
    this.docs = (await this.client.repository().query({
      pageProvider: 'document_content',
      queryParams: [this.docId]
    })).entries;
  }

  async expand() {
    await this._fetchChildren();
    // Toggle the accordion
    this.shadowRoot.querySelector(".ui.accordion .title").classes.add("active");
    this.shadowRoot.querySelector(".ui.accordion .content").classes.add("active");
    // Toggle the icon
    this.shadowRoot.querySelector(".icon").classes.remove("expand").add("collapse");
  }

  async toggle(event, detail, target) {
    await this._fetchChildren();

    var classes = this.shadowRoot.querySelector(".icon").classes;

    // Currently expanded - the according will collapse
    if (target.classes.contains("collapse")) {
      classes.remove("collapse");
      classes.add("expand");
      return;
    }

    // Currently collapsed - expand and add the collapse icon
    classes.remove("expand");
    classes.add("collapse");
  }

  set selected(flag) {
    var classes = this.shadowRoot.querySelector(".label").classes;
    (flag)? classes.add("selected") : classes.remove("selected");
  }

  get selected() { return this.shadowRoot.querySelector(".label").classes.includes("selected"); }

  toggleSelection(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    this.shadowRoot.querySelector(".label").classes.toggle("selected");
    dispatchEvent(new CustomEvent("nodeselected", {detail: this.doc}));
  }
}

@customElement('nuxeo-tree')
class Tree extends Connected(LitElement) {

  private _selection: string[];

  @property() _root: Document;
  @property() multiple: boolean;
  @property() key: string = 'uid';

  // Only render if root key is set
  shouldUpdate() {
    return !!this._root;
  }

  render() {
    return html`<nuxeo-tree-node docid="${this._root.uid}" @nodeselected="${(e) => this.nodeSelected(e.detail)}"></nuxeo-tree-node>`;
  }
  
  set selected(v: any) {
    if (!(v instanceof Array)) {
      v = [v];
    }
    this._selection = v.filter((i) => i != null);
  }

  get selected() {
    if (this.multiple) {
      return this._selection;
    }
    return this._selection.length ? this._selection[0] : null;
  }

  firstUpdated() {
    accordion(this.shadowRoot.querySelector(".ui.accordion"));
  }

  onConnected() {
    //this.rootChanged();
  }

  set rootpath(root) {
    console.log('rootpath');
    /// Fetch the root's key value
    this.client.repository().fetch(root).then(doc => this._root = doc);
  }

  get rootpath() {
    return this._root && this._root.path;
  }

  _expandRoot() {
    //(this.shadowRoot.querySelector("nuxeo-tree-node") as Node).expand();
  }

  deleteNode(docId) {
    this._unselect(docId);
    this.shadowRoot.querySelectorAll("* /deep/ nuxeo-tree-node").find((node) => node.docId == docId).remove();
  }

  nodeSelected(doc) {

    var oldValue = this.selected;

    // New selection
    if (!this._selection.includes(doc.uid)) {
      // Clear others if not multiple
      if (!this.multipleSelection) {
        this._clearSelections(this.shadowRoot);
      }
      this._select(doc.uid);
    } else { // Remove existing selection
      this._unselect(doc.uid);
    }
    
    // notifyPropertyChange(#selected, oldValue, selected);
  }

  _clearSelections(domRoot) {
    this.shadowRoot.querySelectorAll("nuxeo-tree-node").forEach((n) => {
      if (this._selection.includes(n.docid)) {
        n.selected = false;
        this._unselect(n.docid);
      }
      this._clearSelections(n.shadowRoot);
    });
  }

  _select(docId) {
    this._selection.push(docId);
  }

  _unselect(docId) {
    this._selection.splice(this._selection.indexOf(docId), 1);
  }
}
