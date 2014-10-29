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

library nx_request_options;

import 'ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart';

/// A form bound to a [NXConnection] that allows settings global request options.
@CustomTag("nx-request-options")
class NXRequestOptions extends NXElement {

  Duration _timeout;
  List<String> _schemas;
  String _repository;
  
  var contentEnrichers = toObservable({
    "acls": false,
    "thumbnail": false,
    "preview": false,
    "permissions": false
  });

  NXRequestOptions.created() : super.created() {
  }

  onConnect() {
    timeout = NX.timeout;
    schemas = NX.schemas;
    repository = NX.repositoryName;
    if (NX.headers["X-NXContext-Category"] != null) {
      NX.headers["X-NXContext-Category"].split(",").forEach((k) { contentEnrichers[k] = true; });
    }
    contentEnrichers.changes.listen((_) {
      NX.headers["X-NXContext-Category"] = contentEnrichers.keys.where((k) => contentEnrichers[k]).join(",");
    });
  }

  //TODO(nfgs): Consider using a path observer
  @observable get timeout => _timeout;
  @observable set timeout(t) {
    NX.timeout = t;
    _timeout = notifyPropertyChange(#timeout, _timeout, NX.timeout);
  }

  @observable get schemas => _schemas;
  @observable set schemas(s) {
    NX.schemas = s;
    _schemas = notifyPropertyChange(#schemas, _schemas, NX.schemas);
  }

  @observable get repository => _repository;
  @observable set repository(r) {
    NX.repositoryName = r;
    _repository = notifyPropertyChange(#repository, _repository, NX.repositoryName);
  }

  // Filters
  var inSeconds = new DurationToSeconds();
  var asCSV = new ListToCSV();
}

class DurationToSeconds extends Transformer<String, Duration> {
  DurationToSeconds();
  String forward(Duration d) => d.inSeconds.toString();
  Duration reverse(String s) => (s == null || s.isEmpty) ? new Duration() : new Duration(seconds: int.parse(s));
}

class ListToCSV extends Transformer<String, List> {
  ListToCSV();
  String forward(List l) => l.join(",");
  List reverse(String s) => s.split(",").map((s) => s.trim()).toList();
}
