library nx_request_options;

import 'ui_module.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart';

@CustomTag("nx-request-options")
class NXRequestOptions extends NXElement {

  Duration _timeout;
  List<String> _schemas;
  String _repository;

  NXRequestOptions.created() : super.created() {
  }

  onConnect() {
    timeout = NX.timeout;
    schemas = NX.schemas;
    repository = NX.repositoryName;
  }

  //TODO(nfgs): Consider using a path observer
  /// Global request options
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