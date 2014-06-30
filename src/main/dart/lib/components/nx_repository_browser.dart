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

import 'dart:html';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';
import 'semantic.dart';

/// Model for the [NXRepositoryBrowser] module.
class RepositoryBrowser extends Module {
  String title = "Repository",
         icon = "repository.png",
         description = "Browse your repository and discover the properties of your documents.",
         action = "Explore",
         tag = NXRepositoryBrowser.TAG;
}

/// The Repository Browser module element.
@CustomTag(NXRepositoryBrowser.TAG)
class NXRepositoryBrowser extends NXModule with SemanticUI {

  static const String TAG = "nx-repository-browser";

  @published String documentId;

  @observable nuxeo.Document document;

  NXRepositoryBrowser.created() : super.created() {
  }

  documentIdChanged() {
    if (documentId == null) {
      document = null;
    } else {
      NX.doc(documentId).fetch().then((doc) { document = doc; });
    }
  }
}