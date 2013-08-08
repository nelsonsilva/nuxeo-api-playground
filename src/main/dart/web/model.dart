library model;

import 'package:web_ui/observe.dart';
import 'package:nuxeo_automation/browser_client.dart' as nuxeo;

nuxeo.Client NX = null;

var nuxeoUrl = "http://localhost:8080/nuxeo/site/automation";

@observable
bool isConnected = false;

@observable
Map<String, List> categories = toObservable({});

connect() {

  NX = new nuxeo.Client(url: nuxeoUrl);

  NX.registry.then((nuxeo.OperationRegistry registry) {
    isConnected = true;
    registry.ops.forEach((name, nuxeo.Operation op) {
      if (!categories.containsKey(op.category)) {
        categories[op.category] = toObservable([]);
      }
      categories[op.category].add(op);
    });
  });
}


