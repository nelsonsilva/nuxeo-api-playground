library model;

import 'package:nuxeo_automation/client.dart' as nuxeo;

String NUXEO_URL = "http://localhost:8080/nuxeo";
nuxeo.Client NX = null;

class Alert {
  String style;
  String title;
  String message;
  Alert.danger(this.title, this.message) : style = "danger";
}