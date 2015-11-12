/*
 * (C) Copyright 2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     Nelson Silva <nelson.silva@inevo.pt>
 */

library nx_repository_browser;

import 'dart:convert';
import 'dart:html';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'nx_web_adapters.dart' show NxWebAdapter;
import 'ui_module.dart';
import 'semantic.dart';
import 'tree/tree.dart';

/// Model for the [NXRepositoryBrowser] module.
class RepositoryBrowser extends Module {
  String title = "Repository",
         icon = "repository.png",
         description = "Browse the repository you are connected to and discover the content that is inside.",
         action = "Explore",
         tag = NXRepositoryBrowser.TAG;
}

/// The Repository Browser module element.
@CustomTag(NXRepositoryBrowser.TAG)
class NXRepositoryBrowser extends NXModule with SemanticUI, ChangeNotifier {

  static const String TAG = "nx-repository-browser";

  @reflectable @published String get documentId => __$documentId; String __$documentId; @reflectable set documentId(String value) { __$documentId = notifyPropertyChange(#documentId, __$documentId, value); }

  @reflectable @observable nuxeo.Document get document => __$document; nuxeo.Document __$document; @reflectable set document(nuxeo.Document value) { __$document = notifyPropertyChange(#document, __$document, value); }

  @reflectable @published nuxeo.Request get request => __$request; nuxeo.Request __$request; @reflectable set request(nuxeo.Request value) { __$request = notifyPropertyChange(#request, __$request, value); }
  @reflectable @observable dynamic get response => __$response; dynamic __$response; @reflectable set response(dynamic value) { __$response = notifyPropertyChange(#response, __$response, value); }

  @reflectable @observable NxWebAdapter get adapter => __$adapter; NxWebAdapter __$adapter; @reflectable set adapter(NxWebAdapter value) { __$adapter = notifyPropertyChange(#adapter, __$adapter, value); }

  @reflectable @observable String get body => __$body; String __$body; @reflectable set body(String value) { __$body = notifyPropertyChange(#body, __$body, value); }
  /// The id of the referenced Batch Upload.
  @reflectable @observable dynamic get batch => __$batch; dynamic __$batch; @reflectable set batch(dynamic value) { __$batch = notifyPropertyChange(#batch, __$batch, value); }

  @reflectable @observable String get method => __$method; String __$method = "GET"; @reflectable set method(String value) { __$method = notifyPropertyChange(#method, __$method, value); }

  final List errors = toObservable([]);

  NXRepositoryBrowser.created() : super.created() {
  }

  documentIdChanged() {
    method = 'GET';
    body = null;

    if (documentId == null) {
      document = null;
    } else {
      request = NX.doc(documentId);

      runRequest()
      .then(request.handleResponse)
      .then((document) {
        this.document = document;
      });
    }
  }

  adapterChanged() {
    var base = NX.doc(documentId);
    request.uri = base.uri; // reset the request uri
    if (adapter != null) {
      request.adapt(adapter.name);
    }
  }

  runRequest() {
    if (adapter != null) {
      adapter.params
      .where((p) => p.isQueryParam && !p.isEmpty)
      .forEach((param) {
        request.param(param.name, param.value);
      });
    }
    return request.method(method).execute()
      .then(_handleResponse)
      .catchError((e) {
        if (e is nuxeo.ClientException) {
          // Store the response
          this.response = e.response;
          errors.add(e.message);
        }
      });
  }

  _handleResponse(response) {
    this.response = response;

    // if current document was deleted remove the node from the tree
    if (method == 'DELETE') {
      (shadowRoot.querySelector("#tree") as Tree).deleteNode(this.documentId);
    }

    return response;
  }

  documentChanged() {

    async((_) {
      // activate the accordions
      accordion("#adapters");
      accordion("#enrichers");
      accordion("#options");

      // activate the tabs
      shadowRoot.querySelectorAll("#methods .item").forEach((e) {
        e.onClick.listen((event) {
          method = event.target.dataset["method"];
        });
      });
    });
  }

  setDefaultBody() {
    var json = JSON.decode(response.body);
    body = new JsonEncoder.withIndent(" " * 2).convert(json);
  }

  referenceBatch(Event e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    async((_) {
      modal('.ui.modal');
    });
  }

  methodChanged() {
    errors.clear();
    shadowRoot.querySelectorAll("#methods .item").forEach((Element e) {
      if (e.dataset["method"] == method) {
        e.classes.add("active");
      } else {
        e.classes.remove("active");
      }
    });
  }
}