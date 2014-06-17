library nx_schema;

import 'package:polymer/polymer.dart';
import 'ui_filters.dart';
import '../doctypes.dart' as nuxeo;

@CustomTag("nx-schema")
class NXSchema extends PolymerElement with SearchFilter {

  @published nuxeo.Schema schema;

  NXSchema.created() : super.created();
}