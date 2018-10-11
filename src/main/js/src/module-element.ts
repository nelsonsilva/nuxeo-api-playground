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

import { LitElement, property } from '@polymer/lit-element';
import { Connected } from './connection';

export class ModuleElement extends Connected(LitElement) {

  @property() id: string;
  @property() title?: string;
  @property() icon?: string;
  @property() description?: string;
  @property() link?: string;
  @property() action?: string;

  @property() active: boolean = false;

  constructor(id: string) {
    super();
    this.id = id;
  }
  // Only render this page if it's actually visible.
  shouldUpdate() {
    return this.active;
  }

  onConnected() {
    if (this.active) {
      this.onActivate && this.onActivate();
    }
  }

  update(changedProps) {
    super.update(changedProps);
    if (changedProps.has('active') && this.active && this.isConnected) {
      this.onActivate && this.onActivate();;
    }
  }

  _locationChanged() {
    const path = decodeURIComponent(window.location.pathname);
    if (path === '/') {
      return;
    }
    const [ module, ...rest] = path.slice(1).split('/');
    if (module === this.id) {
      this._route = rest;
      this.route(...rest);
    }
  }
}