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
  GridCSS
} from './semantic';

import { StyleCSS } from './shared-styles';

@customElement('nuxeo-batch-uploads')
export class BatchUploads extends ModuleElement {

  constructor() {
    super('uploads');
    this.title = "Batch Upload";
    this.icon = "batch_upload.png";
    this.description = "Create batches by uploading any number of files. These batches can later be referenced in Resource endpoints methods by clicking on the “Reference a batch” button.";
    this.action = "Upload";
    this.errors = [];
  }

  render() {

    const {title, icon, description } = this;
    
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
      ${StyleCSS}
    </style>

    <!-- Main page -->
    <div class="ui page grid">
      <div id="main" class="column">

        <!-- Breadcrumb -->
        <div class="ui segment">
         <div class="ui breadcrumb">
          <a class="section" href="/"><i class="ui home icon"></i></a>
          <div class="divider"> / </div>
          <a class="section" href="/${this.id}">${title}</a>
          </div>
        </div>

        <!-- Help -->
        <div class="ui basic segment">
          <img class="ui small left floated image" src="../images/${icon}">
          <p>${description}</p>

          The default way Resources and Command (Automation) APIs deal with Blobs is to use the standard HTTP MultiPart Encoding.
This strategy can not fit when:
<ul>
<li>Your client does not natively support multipart encoding; 
Ex: JavaScript (without using a Form), Android SDK 2.x.</li>
<li>You have several files to send, but prefer to send them as separated chunk;Ex: You have an HTTP proxy that will limit POST size.</li>
<li>You want to upload files as soon as possible and then run the operation when everything has been uploaded on the server; 
Ex: You upload pictures you select from a mobile device.</li>
</ul>
In those situations, the Batch endpoint provides you a way for first uploading a set of files, then be able to reference that set of files from the API.
You should read the <a target="alt" href="http://doc.nuxeo.com/nxdoc/batch-upload-endpoint">dedicated documentation page</a> for understanding more about this endpoint. In this API playground, we allow you to upload multiple batches (you just need to change the id), and then to reference those batches both in the Resources section and in the Command one (for operations that accepts blob/blobs in input).
        
        </div>

        <!-- Create -->
        <h4 class="ui top attached header">
          New Batch
        </h4>
        <div id="batch" class="ui form segment attached">
        </div>

        <!-- Uploads list -->
        <nuxeo-batch-reference id="batches"></nuxeo-batch-reference>

      </div>
    </div>
    `;
  }

  /*
  domReady() {
    _newBatch();
  }

  onUpload(Event event) {
    ($["batches"] as NXBatchReference).addBatch((event.target as NXBatch).batchId);
    _newBatch();
  }

  void _newBatch() {
    var batch = new Element.tag(NXBatch.TAG) as NXBatch
    ..connectionId = connectionId
    ..on[NXBatch.UPLOAD_EVENT].listen(onUpload);

    $["batch"]
    ..nodes.clear()
    ..append(batch);
  }
  */
}
