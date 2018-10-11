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
import '../vendor/jquery-2.0.3.min.js';
import '../vendor/semantic-0.15.4.min.js';

declare var jQuery;

export const accordion = (elem: HTMLElement) => {
  jQuery(elem).accordion();
};

export const sidebar = (selectorsOrEl, ...params) => { 
  jQuery(selectorsOrEl).sidebar(...params);
};

export const modal = (selectorsOrEl) => {
  var jqEl = jQuery(selectorsOrEl);
  jqEl.modal({'detachable': false});
  jqEl.modal('show');
};

const ButtonCSS = require('../semantic/elements/button.min.css');
const IconCSS = require('../semantic/elements/icon.min.css');
const ImageCSS = require('../semantic/elements/image.min.css');
const InputCSS = require('../semantic/elements/input.min.css');
const HeaderCSS = require('../semantic/elements/header.min.css');
const LabelCSS = require('../semantic/elements/label.min.css');
const LoaderCSS = require('../semantic/elements/loader.min.css');
const SegmentCSS = require('../semantic/elements/segment.min.css');

const BreadcrumbCSS = require('../semantic/collections/breadcrumb.min.css');
const FormCSS = require('../semantic/collections/form.min.css');
const GridCSS = require('../semantic/collections/grid.min.css');
const MessageCSS = require('../semantic/collections/message.min.css');
const MenuCSS = require('../semantic/collections/menu.min.css');
const TableCSS = require('../semantic/collections/table.min.css');

const AccordionCSS = require('../semantic/modules/accordion.min.css');
const CheckboxCSS = require('../semantic/modules/checkbox.min.css');
const DimmerCSS = require('../semantic/modules/dimmer.min.css');
const DropdownCSS = require('../semantic/modules/dropdown.min.css');
const ModalCSS = require('../semantic/modules/modal.min.css');
const SidebarCSS = require('../semantic/modules/sidebar.min.css');
const TabCSS = require('../semantic/modules/tab.min.css');
const TransitionCSS = require('../semantic/modules/transition.min.css');

const ListCSS = require('../semantic/views/list.min.css');

export {
  ButtonCSS,
  IconCSS,
  ImageCSS,
  InputCSS,
  HeaderCSS,
  LabelCSS,
  LoaderCSS,
  SegmentCSS,
  BreadcrumbCSS,
  FormCSS,
  GridCSS,
  MessageCSS,
  MenuCSS,
  TableCSS,
  AccordionCSS,
  CheckboxCSS,
  DropdownCSS,
  DimmerCSS,
  ModalCSS,
  SidebarCSS,
  TabCSS,
  TransitionCSS,
  ListCSS
}