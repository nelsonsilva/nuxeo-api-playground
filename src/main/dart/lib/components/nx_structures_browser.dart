library nx_structures_browser;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:js' as js;
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../doctypes.dart' as nuxeo;
import 'ui_filters.dart';
import 'ui_module.dart';
import 'nx_connection.dart';
import '../yuml.dart' as yuml;

class Selection extends Observable {
  @observable var type;
  @observable var id;
  @observable var item;
}

@CustomTag(NXStructuresBrowser.TAG)
class NXStructuresBrowser extends NXModule with SearchFilter {

  static const String TAG = "nx-structures-browser";

  String title = "Data Structures",
         icon = "images/data_structure.png",
         description = "Browse all the available definitions of types, schemas and properties held by a document.",
         action = "Browse";

  final Map<String, List> items = toObservable({
    "schemas": [],
     "facets": [],
     "types": []});

  List<nuxeo.Schema> get schemas => items["schemas"];
  List<nuxeo.Facet> get facets => items["facets"];
  List<nuxeo.Doctype> get doctypes => items["types"];

  @observable Selection selection = null;

  factory NXStructuresBrowser() => new Element.tag(TAG);

  // This lets the CSS "bleed through" into the Shadow DOM of this element.
  bool get applyAuthorStyles => true;

  yuml.DiagramGenerator _diagram;

  NXStructuresBrowser.created() : super.created() {
  }

  enteredView() {
    // Setup the accordion
    jQuery(".ui.accordion").callMethod('accordion', []);

    // Wait for the DOM to be updated
    onDomChange('#main', () {
      if (selection.item != null) {
         jQuery('#diagram').callMethod('popup', [new js.JsObject.jsify({
           "on": "click",
           "position": "bottom right",
           "html": "<img src='$_currentItemDiagram'>"
         })]);
        }
    });

  }

  get _currentItemDiagram {
    if (selection.item is nuxeo.Doctype) {
      return _diagram.generateForDoctype(selection.item.name);
    }
  }

  @override
  String labelFor(item) => item.toString();

  @override
  onConnect() {

    Future.wait([

    // Schemas
    NX.schemas().then((response) {
      schemas
        ..clear()
        ..addAll(
            JSON.decode(response.body).map((s)
                => new nuxeo.Schema.fromJSON(s)));
    }),

    // Facets
    NX.facets().then((response) {
      facets
      ..clear()
      ..addAll(
          JSON.decode(response.body).map((s)
              => new nuxeo.Facet.fromJSON(s)));
    }),

    // Doctypes
    NX.types().then((response) {
      doctypes.clear();

      JSON.decode(response.body)["doctypes"].forEach((k, v) {
        doctypes.add(new nuxeo.Doctype(k,
            parent: v["parent"],
            schemas: v["schemas"],
            facets: v["facets"]));
      });
    })])

    .then((_) {
      // Check for a selected item
      selectionChanged();
      // Setup the diagram generator
      _diagram = new yuml.DiagramGenerator(schemas: schemas, facets: facets, doctypes: doctypes);
    })
    .catchError((e) {
      connection.alerts.add(
        new Alert.danger("Oh snap!", "Please check the Nuxeo URL and try connecting again.")
      );
      return false;
    });

  }

  void selectionChanged() {
    if (selection != null && items[selection.type].isNotEmpty) {
      selection.item = items[selection.type].where((d) => d.name == selection.id).first;
    }
  }

  @override
   void setupRoutes(Route route) {
    route.addRoute(
        name: 'home',
        path: '',
        enter: (e) {
          selection = null;
        }
    );
     route.addRoute(
         name: 'view',
         path: '/:type/:id',
         enter: (e) {
           selection = new Selection()
           ..type = e.parameters['type']
           ..id = e.parameters['id'];
         },
         leave: (e) {
           jQuery('#diagram').callMethod('popup', ['remove']);
         }
     );
   }

  select(event, detail, target) {
    // <type>-<id>
    var id = target.dataset["id"].split("-");
    router.go("$path.view", {"type": id[0], "id": id[1]});
  }
}